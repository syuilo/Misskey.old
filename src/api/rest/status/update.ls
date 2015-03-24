require! {
	async
	fs
	gm
	'../../../models/status': Status
	'../../../models/status-image': StatusImage
	'../../../models/status-mention': StatusMention
	'../../../models/utils/get-status-before-talk'
	'../../../models/utils/status-response-filter'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../utils/streaming': Streamer
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) -> Status.find-one { user-id: user.id }, (, status) ->
	text = if req.body.text? then req.body.text else ''
	in-reply-to-status-id = if req.body.in_reply_to_status_id? then req.body.in_reply_to_status_id else null
	text .= trim!
	switch
	| status? && text == status.text => res.api-error 400 'Duplicate content'
	| (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image-quality = user.is-premium ? 80 : 60
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
					user.id
	| _ => create do
		req
		res
		app.id
		in-reply-to-status-id
		no
		null
		text
		user.id

function create(req, res, app-id, in-reply-to-status-id, is-image-attached, image, text, user-id)
	Status.insert { 
		app-id
		in-reply-to-status-id
		is-image-attached
		text
		user-id
	} (, status) ->
		| is-image-attached => StatusImage.insert { status-id: status.id, image } send-response
		| _ => send-response!

	function send-response()
		status-response-filter status, (obj) ->
			get-more-talk obj.reply, (talk) ->
				obj.more-talk = talk if obj.reply != null && obj.reply.is-reply
				send obj

	function send(obj)
		res.api-render obj
		stream-obj = JSON.stringify do
			type: \post
			value: obj

		Streamer.publish 'userStream:' + user-id stream-obj

		UserFollowing.find { followee-id: user-id } (followings) ->
			| followings? => followings.for-each (following) ->
				Streamer.publish 'userStream:' + following.follower-id, stream-obj

		mentions = obj.text.match /@[a-zA-Z0-9_]+/g
		if mentions? then mentions.for-each (mention-sn) ->
			mention-sn .= replace '@' ''
			User.find-one { screen-name: mention-sn } (reply-user) ->
				| reply-user? => StatusMention.insert { status-id: obj.id, user-id: reply-user.id } (,) ->
					stream-mention-obj = JSON.stringify do
						type: \reply
						value: obj
					Streamer.publish 'userStream:' + reply-user.id, stream-mention-obj

	function get-more-talk(status, callback)
		get-status-before-talk status.in-reply-to-status-id, (more-talk) ->
			async.map more-talk, (talk-post, map-next) ->
				talk-post.is-reply = talk-post.in-reply-to-status-id != 0 && talk-post.in-reply-to-status-id != null
				User.find-by-id talk-post.user-id, (, talk-post-user) ->
					talk-post.user = talk-post-user
					map-next null talk-post
			, (, more-talk-posts) ->
				callback more-talk-posts
