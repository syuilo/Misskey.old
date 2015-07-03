require! {
	'../../utils/publish-redis-streaming'
	'../../models/talk-message': TalkMessage
}

module.exports = (app, user, message-id, text) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	if null-or-empty message-id
		throw-error \empty-message-id 'Empty message-id.'
	else
		text .= trim!
		(err, message) <- TalkMessage.find-by-id message-id
		switch
		| err? => throw-error \message-find-error err
		| message? => throw-error \message-not-found 'Message not found.'
		| not message.is-image-attached and empty text => throw-error \empty-text 'Empty text.'
		| message.user-id != user.id => throw-error \not-author 'Message that you have sent only can not be modified.'
		| message.is-deleted => throw-error \message-has-been-deleted 'Message has been deleted.'
		| _ =>
			message
				..text = text
				..is-edited = yes
			err <- message.save
			resolve message
			
			# Streaming events
			publish-redis-streaming "talkStream:#{message.otherparty-id}-#{user.id}" to-json do
				type: \otherpartyMessageUpdate
				value: obj
			publish-redis-streaming "talkStream:#{user.id}-#{message.otherparty-id}" to-json do
				type: \meMessageUpdate
				value: obj
