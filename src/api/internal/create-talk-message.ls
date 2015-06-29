require! {
	fs
	gm
	'../../models/talk-message': TalkMessage
	'../../models/talk-message-image': TalkMessageImage
	'../../models/user-following': UserFollowing
	'../../models/utils/user-following-check'
	'../../utils/publish-redis-streaming'
}

module.exports = (app, user, otherparty-id, text, image = null) ->
	resolve, reject <- new Promise!
	text .= trim!
	switch
	| !image? && null-or-empty text => reject 'Empty text.'
	| null-or-empty otherparty-id => reject 'Empty otherparty-id'
	| _ => user-following-check otherparty-id, user.id .then (is-following) ->
		| !is-following => reject 'You are not followed from this user. To send a message, you need to have been followed from the other party.'
		| image? =>
			image-quality = if user.is-plus then 70 else 50
			gm image
				..compress \jpeg
				..quality image-quality
				..to-buffer \jpeg (, buffer) ->
					create buffer
		| _ => create null

	function create(image)
		talk-message = new TalkMessage {
			app-id: if app? then app.id else null
			user-id: user.id
			otherparty-id
			text
			is-image-attached: image?
		}
		err, created-talk-message <- talk-message.save
		if err?
			reject err
		else
			switch
			| image? =>
				talk-message-image = new TalkMessageImage {message-id: created-talk-message.id, image}
				talk-message-image.save ->
					send-response created-talk-message
			| _ =>
				send-response created-talk-message

	function send-response(message)
		resolve message

		[
			["userStream:#{otherparty-id}" \talk-message]
			["talkStream:#{otherparty-id}-#{user.id}" \otherparty-message]
			["talkStream:#{user.id}-#{otherparty-id}" \me-message]
		] |> each ([channel, type]) ->
			publish-redis-streaming channel, to-json {type, value: {id: message.id}}
