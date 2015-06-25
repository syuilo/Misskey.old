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
	(, recent-status) <- Status.find-one {user-id: user.id} .sort \-createdAt .exec 
	text .= trim!
	switch
	| recent-status? && text == recent-status.text => reject 'Duplicate content.'
	| image? =>
		image-quality = if user.is-plus then 80 else 60
		gm path
			.compress \jpeg
			.quality image-quality
			.to-buffer \jpeg (, buffer) ->
				create buffer
	| _ => create null

	function create(image)
		status = new Status do
			app-id: app.id
			in-reply-to-status-id: in-reply-to-status-id
			is-image-attached: image?
			text: text
			user-id: user.id
		err, created-status <- status.save
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
									value: {status.id}
								publish-redis-streaming "userStream:#{reply-user.id}" stream-mention-obj
