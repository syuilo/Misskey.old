require! {
	'../../models/talk-message': TalkMessage
	'../../models/utils/get-talk-timeline'
}

module.exports = (app, user, otherparty-id, limit, since-cursor, max-cursor) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	get-talk-timeline do
		user.id
		otherparty-id
		limit
		since-cursor
		max-cursor
	.then (messages) ->
		resolve messages
		
		# 既読にする
		messages |> each (message) ->
			if message.user-id.to-string! == otherparty-id.to-string!
				message
					..is-readed = yes
					..save!