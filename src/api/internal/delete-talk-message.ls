require! {
	'../../utils/publish-redis-streaming'
	'../../models/talk-message': TalkMessage
	'../../models/utils/filter-talk-message-for-response'
}

module.exports = (app, user, message-id) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	switch
	| !message-id? => throw-error \empty-message-id 'Empty message-id.'
	| _ => TalkMessage.find-by-id message-id, (, talk-message) ->
		| !talk-message? => throw-error \message-not-found 'Message not found.'
		| talk-message.user-id.to-string! != user.id.to-string! => throw-error \message-access-denied 'Message that you have sent only can not be delete'
		| talk-message.is-deleted => throw-error \message-has-been-deleted 'This message has already been deleted.'
		| _ =>
			talk-message.is-deleted = yes
			talk-message.save (err) ->
				resolve talk-message
				publish-redis-streaming "talkStream:#{talk-message.otherparty-id}-#{user.id}", to-json do
					type: \otherparty-message-delete
					value: talk-message.id
				publish-redis-streaming "talkStream:#{user.id}-#{talk-message.otherparty-id}", to-json do
					type: \me-message-delete
					value: talk-message.id
