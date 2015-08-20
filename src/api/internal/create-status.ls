require! {
	fs
	gm
	'image-type': image-type
	'../../models/status': Status
	'../../models/status-mention': StatusMention
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../models/utils/serialize-status'
	'../../models/utils/filter-user-for-response'
	'./create-notice'
	'../../utils/publish-redis-streaming'
	'../../utils/register-image'
}

module.exports = (app, user, text, in-reply-to-status-id, image = null, repost-from-status = null) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	text .= trim!
	switch
	| !image? && !repost-from-status? && null-or-empty text => throw-error \empty-text 'Empty text.'
	| not null-or-empty text and text[0] == \$ => analyze-command text
	| text.length > 300chars => throw-error \too-long-text 'Too long text.'
	| _ =>
		(, recent-status) <- Status.find-one {user-id: user.id} .sort \-createdAt .exec 
		switch
		| recent-status? && text == recent-status.text && !image? && !repost-from-status? => throw-error \duplicate-content 'Duplicate content.'
		| image? =>
			# Detect the image type
			img-type = (image-type image).ext
			switch (img-type)
			| \gif =>
				if user.is-plus
					create image, \gif
				else
					throw-error \denied-gif-upload 'Denied GIF upload (plus-account only).'
			| _ => 
				image-quality = if user.is-plus then 80 else 60
				gm image
					.compress \jpeg
					.quality image-quality
					.to-buffer \jpeg (err, buffer) ->
						if err? || !buffer?
							throw-error \failed-attach-image 'Failed attach image.'
						else
							create buffer, \jpg
		| _ => create null, null

	function create(image, img-type)
		if in-reply-to-status-id?
			(err, reply-status) <- Status.find-by-id in-reply-to-status-id
			if reply-status?
				status = new Status do
					app-id: if app? then app.id else null
					in-reply-to-status-id: if reply-status.repost-from-status-id? then reply-status.repost-from-status-id else in-reply-to-status-id
					is-image-attached: image?
					text: text
					user-id: user.id
					repost-from-status-id: if repost-from-status? then repost-from-status.id else null
				err, created-status <- status.save
				if err?
					reject err
				else
					created created-status
			else
				throw-error \reply-status-not-found 'Reply status not found.'
		else
			status = new Status do
				app-id: if app? then app.id else null
				in-reply-to-status-id: null
				is-image-attached: image?
				text: text
				user-id: user.id
				repost-from-status-id: if repost-from-status? then repost-from-status.id else null
			err, created-status <- status.save
			if err?
				reject err
			else
				created created-status
	
	function created(created-status)
		if repost-from-status?
			reposted created-status
		user.statuses-count++
		user.save ->
			if created-status.in-reply-to-status-id?
				Status.find-by-id created-status.in-reply-to-status-id, (, reply-to-status) ->
					if reply-to-status?
						reply-to-status.replies-count++
						if !reply-to-status.replies? or !reply-to-status.replies.0?
							reply-to-status.replies = [created-status._id]
						else
							reply-to-status.replies.push created-status._id
						reply-to-status.save!
			switch
			| image? =>
				image-name = "#{created-status.id}-1.#{img-type}"
				register-image user, \status-image image-name, img-type, image .then (path) ->
					created-status.images = [path]
					created-status.save ->
						done!
			| _ => done!

			function done
				resolve created-status

				stream-obj = to-json do
					type: \status
					value: {id: created-status.id}

				publish-redis-streaming "userStream:#{user.id}" stream-obj

				UserFollowing.find {followee-id: user.id} (, followings) ->
					| !empty followings => followings |> each ((following) -> publish-redis-streaming "userStream:#{following.follower-id}" stream-obj)

				mentions = created-status.text == /@[a-zA-Z0-9_]+/g
				if mentions?
					mentions |> each (mention-sn) ->
						mention-sn .= replace '@' ''
						(, reply-user) <- User.find-one {screen-name-lower: mention-sn.to-lower-case!}
						if reply-user?
							status-mention = new StatusMention do
								status-id: created-status.id
								user-id: reply-user.id
							status-mention.save ->
								stream-mention-obj = to-json do
									type: \reply
									value:
										id: created-status.id
										user-name: user.name
										user-screen-name: user.screen-name
										user-icon-image-url: user.icon-image-url
										text: created-status.text
								publish-redis-streaming "userStream:#{reply-user.id}" stream-mention-obj

	function reposted(created-status)
		repost-from-status
			..reposts-count++
			..save (err) ->
				# Create notice
				create-notice null, repost-from-status.user-id, \status-repost {
					repost-id: created-status.id
					status-id: repost-from-status.id
					user-id: user.id
				} .then ->

				serialize-status repost-from-status, (repost-from-status-obj) ->
					repost-from-status-obj
						..is-repost-to-status = true
						..reposted-by-user = filter-user-for-response user
						.. |> res.api-render
					stream-obj = to-json do
						type: \repost
						value: {created-status.id}
					publish-redis-streaming "userStream:#{user.id}" stream-obj
					UserFollowing.find {followee-id: user.id} (, user-followings) ->
						| !empty user-followings => user-followings |> each (user-following) ->
							publish-redis-streaming "userStream:#{user-following.follower-id}" stream-obj

	function analyze-command(text)
		space-index = text.index-of ' '
		if space-index > 1
			command = text.substr 1char (space-index - 1char)
			argument = text.substr (space-index + 1char)
			switch command
			| \report-image =>
				slash-index = argument.index-of '/'
				if slash-index > 1
					type = argument.substr 0char slash-index
					id = argument.substr (slash-index + 1char)
					promise = switch type
					| \status => (require './disable-status-image') app, user, id
					| \bbs-post => (require './disable-bbs-post-image') app, user, id
					| \talk-message => (require './disable-talk-message-image') app, user, id
					| _ => throw-error \unknown-command-report-image-type "Unknown command report-image type '#{type}'."
					promise.then do
						(image) ->
							resolve null
						(err) ->
							throw-error "report-image-command-#{err.code}" err.message
				else
					throw-error \invalid-command-argument "Invalid command argument."
			| _ => throw-error \unknown-command "Unknown command '#{command}'."
		else
			command = text.substr 1char
			switch command
			| _ => throw-error \unknown-command "Unknown command '#{command}'."
