require! {
	'../../auth': authorize
	'../../../models/talk-message': TalkMessage
	'../../../utils/filter-talk-message-for-response'
}
exports = (req, res) -> authorize req, res, (user, app) ->
	| !(message-id = req.body.message_id)? => res.api-error 400 'message_id parameter is required :('
	| _ => TalkMessage.find-by-id message-id, (, talk-message) ->
		| !talk-message? => res.api-error 404 'Message not found.'
		| talk-message.user-id != user.id => res.api-error 'Message that you have sent only can not be delete'
		| talk-message.is-deleted => res.api-error 400 'This message has already been deleted.'
		| _ => talk-message
			..is-deleted = true
			..save -> filter-talk-message-for-response talk-message, (obj) ->
				res.api-render obj
				Streamer
					..publish \talkStream: + talk-message.otherparty-id + \- + user.id, JSON.stringify do
						type: \otherpartyMessageDelete
						value: talk-message.id
					..publish \talkStream: + user.id + \- + talk-message.otherparty-id, JSON.stringify do
						type: \meMessageDelete
						value: talk-message.id
