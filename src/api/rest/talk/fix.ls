require! {
	'../../auth': authorize
	'../../../utils/publish-redis-streaming'
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/filter-talk-message-for-response'
}

module.exports = (req, res) -> authorize req, res, (user,) ->
	| !(text = req.body.text)? => res.api-error 400 'text parameter is required :('
	| !(message-id = req.body.message_id)? => res.api-error 400 'message_id parameter is required :('
	| _ => TalkMessage.find-by-id message-id, (, talk-message) ->
		| !talk-message? => res.api-error 400 'Message not found'
		| talk-message.user-id != user.id => res.api-error 400 'Message that you have sent only can not be modified.'
		| talk-message.is-deleted => res.api-error 400 'This message has already been deleted.'
		| _ => talk-message
			..text = text
			..is-modified = yes
			..save ->
				obj <- filter-talk-message-for-response talk-message
				res.api-render obj
				publish-redis-streaming "talkStream:#{talk-message.otherparty-id}-#{user.id}" JSON.stringify do
					type: \otherpartyMessageUpdate
					value: obj
				publish-redis-streaming "talkStream:#{user.id}-#{talk-message.otherparty-id}" JSON.stringify do
					type: \meMessageUpdate
					value: obj
