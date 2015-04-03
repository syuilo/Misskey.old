require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../utils/publish-redis-streaming'
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/filter-talk-message-for-response'
}

module.exports = (req, res) -> authorize req, res, (user,) ->
	[text, message-id] = get-express-params req, <[ text message-id ]>
	| empty text => res.api-error 400 'text parameter is required :('
	| empty message-id => res.api-error 400 'messageId parameter is required :('
	| _ => TalkMessage.find-by-id message-id, (, talk-message) ->
		| !talk-message? => res.api-error 400 'Message not found'
		| talk-message.user-id != user.id => res.api-error 400 'Message that you have sent only can not be modified.'
		| talk-message.is-deleted => res.api-error 400 'This message has already been deleted.'
		| _ => talk-message
			..text = text
			..is-modified = yes
			..save (err) ->
				obj <- filter-talk-message-for-response talk-message
				res.api-render obj
				publish-redis-streaming "talkStream:#{talk-message.otherparty-id}-#{user.id}" to-json do
					type: \otherpartyMessageUpdate
					value: obj
				publish-redis-streaming "talkStream:#{user.id}-#{talk-message.otherparty-id}" to-json do
					type: \meMessageUpdate
					value: obj
