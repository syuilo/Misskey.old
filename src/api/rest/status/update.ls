require! {
	async
	fs
	gm
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../utils/publish-redis-streaming'
	'../../../models/utils/serialize-status'
	'../../../models/status': Status
	'../../../models/status-image': StatusImage
	'../../../models/status-mention': StatusMention
	'../../../models/utils/status-get-before-talk'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
}

module.exports = (req, res) -> authorize req, res, (user, app) -> Status.find-one { user-id: user.id }, (, status) ->
	[text, in-reply-to-status-id] = get-express-params req, <[ text, in-reply-to-status-id ]>
	text = if !empty text then text else ''
	in-reply-to-status-id = if !empty in-reply-to-status-id then in-reply-to-status-id else null
	text .= trim!
	switch
	| status? && text == status.text => res.api-error 400 'Duplicate content'
	| (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image-quality = if user.is-plus then 80 else 60
		gm path
			.compress \jpeg
			.quality image-quality
			.to-buffer \jpeg (, buffer) ->
				fs.unlink path
				create do
					req
					res
					app.id
					in-reply-to-status-id
					yes
					buffer
					text
					user
	| _ => create do
		req
		res
		app.id
		in-reply-to-status-id
		no
		null
		text
		user

function create(req, res, app-id, in-reply-to-status-id, is-image-attached, image, text, user)
	status = new Status {app-id, in-reply-to-status-id, is-image-attached,text, user-id: user.id}
		
	status.save (, created-status) ->
		user.statuses-count++
		err <- user.save
		if status.in-reply-to-status-id?
			Status.find-by-id status.in-reply-to-status-id, (, reply-to-status) ->
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
		stream-obj = to-json do
			type: \status
			value: { id: status.id }

		publish-redis-streaming "userStream:#{user.id}" stream-obj

		UserFollowing.find { followee-id: user.id } (, followings) ->
			| !empty followings => each ((following) -> publish-redis-streaming "userStream:#{following.follower-id}" stream-obj), followings

		serialize-status status, (obj) ->
			| obj.reply? =>
				switch
				| obj.reply.is-reply =>
					get-more-talk obj.reply, (talk) ->
						obj.more-talk = talk
						send obj
				| _ => send obj
			| _ => send obj

	function send obj
		res.api-render obj
		mentions = obj.text == /@[a-zA-Z0-9_]+/g
		if mentions? then mentions.for-each (mention-sn) ->
			mention-sn .= replace '@' ''
			User.find-one { screen-name: mention-sn } (, reply-user) ->
				| reply-user? =>
					status-mention = new StatusMention do
						status-id: obj.id
						user-id: reply-user.id
					status-mention.save ->
						stream-mention-obj = to-json do
							type: \reply
							value: obj
						publish-redis-streaming "userStream:#{reply-user.id}" stream-mention-obj

	function get-more-talk(status, callback)
		status-get-before-talk status.in-reply-to-status-id .then (more-talk) ->
			async.map more-talk, (talk-post, map-next) ->
				talk-post.is-reply = talk-post.in-reply-to-status-id?
				User.find-by-id talk-post.user-id, (, talk-post-user) ->
					talk-post.user = talk-post-user
					map-next null talk-post
			, (, more-talk-posts) ->
				callback more-talk-posts
