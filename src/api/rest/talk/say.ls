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
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[text, otherparty-id] = get-express-params req, <[ text otherparty-id ]>
	switch
	| !otherparty-id? => res.api-error 400 'otherparty-id is required :('
	| _ => user-following-check otherparty-id, user.id .then (is-following) ->
		| !is-following => res.api-error 400 'You are not followed from this user. To send a message, you need to have been followed from the other party.'
		| (Object.keys req.files).length == 1 =>
			path = req.files.image.path
			image-quality = if user.is-plus then 70 else 50
			gm path
				..compress \jpeg
				..quality image-quality
				..to-buffer \jpeg (error, buffer) ->
					| error => throw error
					| _ =>
						fs.unlink path
						create app.id, otherparty-id, buffer, true, text, user.id
		| _ => create app.id, otherparty-id, null, false, text, user.id

	function create(app-id, otherparty-id, image, is-image-attached, text, user-id)
		talk-message = new TalkMessage {app-id, user-id, otherparty-id, text, is-image-attached}
		err, created-talk-message <- talk-message.save
		switch
		| is-image-attached =>
			talk-message-image = new TalkMessageImage {message-id: created-talk-message.id, image}
			talk-message-image.save ->
				send-response created-talk-message, user-id, otherparty-id
		| _ =>
			send-response created-talk-message, user-id, otherparty-id

	function send-response(message, user-id, otherparty-id)
		message .= to-object!
		res.api-render message

		[
			["userStream:#{otherparty-id}" \talk-message]
			["talkStream:#{otherparty-id}-#{user-id}" \otherparty-message]
			["talkStream:#{user-id}-#{otherparty-id}" \me-message]
		] |> each ([channel, type]) ->
			publish-redis-streaming channel, to-json {type, value: {id: message.id}}
