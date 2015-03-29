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
	'../../../utils/publish-redis-streaming'
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) -> Status.find-one { user-id: user.id }, (, status) ->
	text = if req.body.text? then req.body.text else ''
	in-reply-to-status-id = req.body\in-reply-to-status-id ? null
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
	status = new Status do
		{
		app-id
		in-reply-to-status-id
		is-image-attached
		text
		user-id: user.id
		}
		
	status.save (, status) ->
		| is-image-attached =>
			status-image = new StatusImage do
				{
				status-id: status.id
				image
				}
			status-image.save send-response
		| _ => send-response!

	function send-response
		status-response-filter status, (obj) ->
			get-more-talk obj.reply, (talk) ->
				obj.more-talk = talk if obj.reply != null && obj.reply.is-reply
				send obj

	function send obj
		res.api-render obj
		stream-obj = to-json do
			type: \post
			value: obj

		publish-redis-streaming "userStream:${user-id}" stream-obj

		UserFollowing.find { followee-id: user-id } (, followings) ->
			| !empty followings => each ((following) -> publish-redis-streaming "userStream:#{following.follower-id}" stream-obj), followings

		mentions = obj.text.match /@[a-zA-Z0-9_]+/g
		if mentions? then mentions.for-each (mention-sn) ->
			mention-sn .= replace '@' ''
			User.find-one { screen-name: mention-sn } (, reply-user) ->
				| reply-user? =>
					status-mention = new StatusMention do
						{
						status-id: obj.id
						user-id: reply-user.id
						}
					status-mention.save ->
						stream-mention-obj = to-json do
							type: \reply
							value: obj
						publish-redis-streaming "userStream:#{reply-user.id}" stream-mention-obj

	function get-more-talk(status, callback)
		get-status-before-talk status.in-reply-to-status-id, (more-talk) ->
			async.map more-talk, (talk-post, map-next) ->
				talk-post.is-reply = talk-post.in-reply-to-status-id != 0 && talk-post.in-reply-to-status-id != null
				User.find-by-id talk-post.user-id, (, talk-post-user) ->
					talk-post.user = talk-post-user
					map-next null talk-post
			, (, more-talk-posts) ->
				callback more-talk-posts
