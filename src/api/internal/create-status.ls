require! {
	fs
	gm
	'../../models/status': Status
	'../../models/status-image': StatusImage
	'../../models/status-mention': StatusMention
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../utils/publish-redis-streaming'
}

module.exports = (app, user, text, in-reply-to-status-id, image = null) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	text .= trim!
	switch
	| !image? && null-or-empty text => throw-error \empty-text 'Empty text.'
	| not null-or-empty text and text[0] == \$ => analyze-command text
	| text.length > 300chars => throw-error \too-long-text 'Too long text.'
	| _ =>
		(, recent-status) <- Status.find-one {user-id: user.id} .sort \-createdAt .exec 
		switch
		| recent-status? && text == recent-status.text => throw-error \duplicate-content 'Duplicate content.'
		| image? =>
			image-quality = if user.is-plus then 80 else 60
			gm image
				.compress \jpeg
				.quality image-quality
				.to-buffer \jpeg (err, buffer) ->
					if err? || !buffer?
						throw-error \failed-attach-image 'Failed attach image.'
					else
						create buffer
		| _ => create null

	function create(image)
		status = new Status do
			app-id: if app? then app.id else null
			in-reply-to-status-id: in-reply-to-status-id
			is-image-attached: image?
			text: text
			user-id: user.id
		err, created-status <- status.save
		if err?
			reject err
		else
			user.statuses-count++
			user.save ->
				if created-status.in-reply-to-status-id?
					Status.find-by-id created-status.in-reply-to-status-id, (, reply-to-status) ->
						if reply-to-status?
							if !reply-to-status.replies? or !reply-to-status.replies.0?
								reply-to-status.replies = [created-status._id]
							else
								reply-to-status.replies.push created-status._id
							reply-to-status.save!
				switch
				| image? =>
					status-image = new StatusImage {status-id: created-status.id, image}
					status-image.save -> done!
				| _ => done!

				function done
					resolve created-status

					stream-obj = to-json do
						type: \status
						value: {id: status.id}

					publish-redis-streaming "userStream:#{user.id}" stream-obj

					UserFollowing.find {followee-id: user.id} (, followings) ->
						| !empty followings => followings |> each ((following) -> publish-redis-streaming "userStream:#{following.follower-id}" stream-obj)

					mentions = status.text == /@[a-zA-Z0-9_]+/g
					if mentions?
						mentions |> each (mention-sn) ->
							mention-sn .= replace '@' ''
							(, reply-user) <- User.find-one {screen-name-lower: mention-sn.to-lower-case!}
							if reply-user?
								status-mention = new StatusMention do
									status-id: status.id
									user-id: reply-user.id
								status-mention.save ->
									stream-mention-obj = to-json do
										type: \reply
										value: {
											id: status.id
											user-name: user.name
											user-screen-name: user.screen-name
											text: status.text
										}
									publish-redis-streaming "userStream:#{reply-user.id}" stream-mention-obj

	function analyze-command(text)
		space-index = text.index-of ' '
		if space-index > 1
			command = text.substr 1char (space-index - 1char)
			argument = text.substr space-index
			switch command
			| \report-image =>
				slash-index = argument.index-of '/'
				if slash-index > 1
					type = argument.substr 0char (slash-index - 1char)
					id = argument.substr (slash-index + 1char)
					promise = switch type
					| \status => (require './disable-status-image') app, user, id
					| \bbs-post => (require './disable-bbs-post-image') app, user, id
					| \talk-message => (require './disable-talk-message-image') app, user, id
					| _ => throw-error \unknown-command-report-image-type "Unknown command report-image type '#{type}'."
					promise.then do
						(image) ->
							resolve \ok
						(err) ->
							throw-error "report-image-command-#{err.code}" err.message
				else
					throw-error \invalid-command-argument "Invalid command argument."
			| _ => throw-error \unknown-command "Unknown command '#{command}'."
		else
			command = text.substr 1char
			switch command
			| _ => throw-error \unknown-command "Unknown command '#{command}'."
