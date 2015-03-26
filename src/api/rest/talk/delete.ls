require! {
	'../../auth': authorize
	'../../../utils/publish-redis-streaming'
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/filter-talk-message-for-response'
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(message-id = req.body.message-id)? => res.api-error 400 'messageId parameter is required :('
	| _ => TalkMessage.find-by-id message-id, (, talk-message) ->
		| !talk-message? => res.api-error 404 'Message not found.'
		| talk-message.user-id != user.id => res.api-error 'Message that you have sent only can not be delete'
		| talk-message.is-deleted => res.api-error 400 'This message has already been deleted.'
		| _ => talk-message
			..is-deleted = yes
			..save (err) -> filter-talk-message-for-response talk-message, (obj) ->
				res.api-render obj
				publish-redis-streaming \talkStream: + talk-message.otherparty-id + \- + user.id, to-json do
					type: \otherpartyMessageDelete
					value: talk-message.id
				publish-redis-streaming \talkStream: + user.id + \- + talk-message.otherparty-id, to-json do
					type: \meMessageDelete
					value: talk-message.id
