require! {
	'../../auth': authorize		
	'../../../config'
	fs
	gm
	'../../../utils/streaming': Streamer
	'../../../models/talk-message': TalkMessage
	'../../../models/talk-message-image': TalkMessageImage
	'../../../models/user-following': UserFollowing
}

exports = (req, res) ->
	authorize req, res, (user, app) ->
		text = if req.body.text? then req.body.text else ''
		otherparty-id = req.body.otherparty_id
		switch
		| !otherparty-id? => res.api-error 400 'otherparty_id parameter is required :('
		| _ => UserFollowing.is-following otherparty-id, user.id, (is-following) ->
			| !is-following => res.api-error 400 'You are not followed from this user. To send a message, you need to have been followed from the other party.'
			| _ => 
				switch
				| Object.keys req.files .length === 1 =>
					path = req.files.image.path
					image-quality = if user.is-premium then 100 else 70
					gm path
						..compress 'jpeg'
						..quality image-quality
						..to-buffer 'jpeg', (error, buffer) ->
							| error => throw error
							| _ => 
								fs.unlink path
								create req, res, app.id, otherparty-id, buffer, true, text, user.id
				| _ => create req, res, res, app.id, otherparty-id, null, false, text, user.id

function create req, res, app-id, otherparty-id, image, is-image-attached, text, user-id
	TalkMessage.create app-id, user-id, otherparty-id, text, is-attached, (talk-message) ->
		if is-image-attached
			TalkMessageImage.create talk-message.id, image, (talk-message-image) ->
		TalkMessage.buildResponseObject talk-message, (obj) ->
			res.api-render obj
			Streamer.publish 'userStream:' + otherparty-id, JSON.stringify do
				type: \talkMessage
				value: obj
			Streamer.publish 'talkStream:' + otherparty-id + '-' + user-id, JSON.stringify do
				type: \otherpartyMessage
				value: obj
			Streamer.publish 'talkStream:' + user-id + '-' + otherparty-id, JSON.stringify do
				type: \meMessage
				value: obj
