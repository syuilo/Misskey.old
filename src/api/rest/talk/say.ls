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
		| req.files.length == 1 =>
			path = req.files.image.path
			image-quality = if user.is-plus then 70 else 50
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
	console.log '#####'
	talk-message = new TalkMessage {app-id, user-id, otherparty-id, text, is-image-attached}
	created-talk-message <- talk-message.save 
	switch
	| is-image-attached =>
		talk-message-image = new TalkMessageImage {message-id: created-talk-message.id, image}
		talk-message-image.save ->
			send-response created-talk-message
	| _ =>
		send-response created-talk-message

function send-response obj
	res.api-render obj
	
	[
		["userStream:#{otherparty-id}" \talk-message]
		["talkStream:#{otherparty-id}-#{user-id}" \otherparty-message]
		["talkStream:#{user-id}-#{otherparty-id}" \me-message]
	] |> each ([channel, type]) ->
		publish-redis-streaming channel, to-json {type, value: obj}
