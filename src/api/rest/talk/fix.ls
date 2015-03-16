require! {
	fs
	'../../auth': authorize
	'../../../models/talk-message': TalkMessage
	'../../../utils/streaming': Streamer
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	text = req.body.text
	message-id = req.body.message_id
	switch
	| text == null => res.api-error 400 'text parameter is required :('
	| message-id == null => res.api-error 400 'message_id parameter is required :('
	| _ => TalkMessage.find message-id, (talk-message) ->
		switch
		| talk-message == null => res.api-error 400 'Message not found.'
		| talk-message.user-id != user.id => res.api-error 400 'Message that you have sent only can not be modified.'
		| talk-message.is-deleted => res.api-error 400 'This message has already been deleted.'
		| _ =>
			talk-message
				..text = text
				..is-modified = true
				.update -> TalkMessage.build-response-object talk-message, (obj) ->
					res.api-render obj
					Streamer
						..publish 'talkStream:' + talk-message.otherparty-id + '-' + user.id, JSON.stringify do
							type: 'otherpartyMessageUpdate'
							value: obj
						..publish 'talkStream:' + user.id + '-' + talk-message.otherparty-id, JSON.stringify do
							type: 'meMessageUpdate'
							value: obj
