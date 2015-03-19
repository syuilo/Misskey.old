require! {
	'../../auth': authorize
	'../../../utils/streaming': Streamer
	'../../../models/talk-message': TalkMessage
}

exports = (req, res) ->
	authorize req, res, (user, app) ->
		message-id = req.body.message_id
		switch
		| !message-id? => res.api-error 400 'message_id parameter is required :('
		| _ => TalkMessage.find message-id, (talk-message)->
			| !talk-message? => res.api-error 404 'Message not found.'
			| talk-message.user-id != user.id => res.api-error 400 'Message that you have sent only can not be delete'
			| talk-message.is-deleted => res.api-error 400 'This message has already been deleted.'
			| _ => 
				talk-message
					..is-deleted = true
					..update ->
						talk-message.buildResponseObject talk-message, (obj) ->
							res.api-render obj
							Streamer.publish 'talkStream:' + talk-message.otherparty-id + '-' + user.id, JSON.stringify do
								type: 'otherpartyMessageDelete'
								value: talk-message.id		
							Streamer.publish 'talkStream:' + user.id + '-' + talk-message.otherparty-id, JSON.stringify do
								type: 'meMessageDelete'
								value: talk-message.id
