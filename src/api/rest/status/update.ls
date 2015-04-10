require! {
	fs
	gm
	'../../../models/status': Status
	'../../../models/status-image': StatusImage
	'../../../models/status-mention': StatusMention
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../utils/publish-redis-streaming'
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) -> Status.find-one {user-id: user.id} .sort \-createdAt .exec (, recent-status) ->
	text = if req.body.text? then req.body.text else ''
	in-reply-to-status-id = req.body\in-reply-to-status-id ? null
	text .= trim!
	switch
	| recent-status? && text == recent-status.text => res.api-error 400 'Duplicate content'
	| (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image-quality = if user.is-plus then 80 else 60
		gm path
			.compress \jpeg
			.quality image-quality
			.to-buffer \jpeg (, buffer) ->
				fs.unlink path
				create yes, buffer
	| _ => create no, null

	function create(is-image-attached, image)
		status = new Status {app-id: app.id, in-reply-to-status-id, is-image-attached, text, user-id: user.id}
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
			| is-image-attached =>
				status-image = new StatusImage {status-id: created-status.id, image}
				status-image.save -> send-response created-status
			| _ => send-response created-status

		function send-response status
			res.api-render status.to-object!
			
			stream-obj = to-json do
				type: \status
				value: {id: status.id}

			console.time status.id
			publish-redis-streaming "userStream:#{user.id}" stream-obj

			UserFollowing.find {followee-id: user.id} (, followings) ->
				| !empty followings => followings |> each ((following) -> publish-redis-streaming "userStream:#{following.follower-id}" stream-obj)
			
			mentions = status.text == /@[a-zA-Z0-9_]+/g
			if mentions?
				mentions |> each (mention-sn) ->
					mention-sn .= replace '@' ''
					(, reply-user) <- User.find-one {screen-name: mention-sn}
					if reply-user?
						status-mention = new StatusMention do
							status-id: status.id
							user-id: reply-user.id
						status-mention.save ->
							stream-mention-obj = to-json do
								type: \reply
								value: {id: status.id}
							publish-redis-streaming "userStream:#{reply-user.id}" stream-mention-obj
