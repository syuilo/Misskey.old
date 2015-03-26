require! {
	fs
	gm
	'../../auth': authorize
	'../../../config'
	'../../../utils/publish-redis-streaming'
	'../../../models/talk-message': TalkMessage
	'../../../models/talk-message-image': TalkMessageImage
	'../../../models/user-following': UserFollowing
	'../../../models/utils/user-following-check'
}

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		text = req.body.text ? ''
		otherparty-id = req.body.otherparty-id
		switch
		| !otherparty-id? => res.api-error 400 'otherpartyId parameter is required :('
		| _ => user-following-check otherparty-id, user.id, (is-following) ->
			| !is-following => res.api-error 400 'You are not followed from this user. To send a message, you need to have been followed from the other party.'
			| _ => 
				switch
				| Object.keys req.files .length == 1 =>
					path = req.files.image.path
					image-quality = if user.is-premium then 70 else 50
					gm path
						..compress \jpeg
						..quality image-quality
						..to-buffer \jpeg (error, buffer) ->
							| error => throw error
							| _ => 
								fs.unlink path
								create req, res, app.id, otherparty-id, buffer, true, text, user.id
				| _ => create req, res, res, app.id, otherparty-id, null, false, text, user.id

function create(req, res, app-id, otherparty-id, image, is-image-attached, text, user-id)
	function send-response obj
		res.api-render obj
		publish-redis-streaming "userStream:#{otherparty-id}", to-json do
			type: \talk-message
			value: obj
		publish-redis-streaming "talkStream:#{otherparty-id}" + '-' + user-id, to-json do
			type: \otherparty-message
			value: obj
		publish-redis-streaming "talkStream:#{user-id}-#{otherparty-id}", to-json do
			type: \meMessage
			value: obj
	TalkMessage.insert {app-id, user-id, otherparty-id, text, is-image-attached} (talk-message) ->
		if is-image-attached
			TalkMessageImage.insert {message-id: talk-message.id, image} (talk-message-image) ->
				send-response talk-message
		else
			send-response talk-message

