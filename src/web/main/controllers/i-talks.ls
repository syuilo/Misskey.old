require! {
	'../../../models/user': User
	'../../../models/talk-message': TalkMessage
	'../../../models/talk-history': TalkHistory
	'../../../models/utils/get-talk-history-messages'
}

module.exports = (req, res) ->
	get-talk-history-messages req.me.id .then (messages) ->
		console.log messages
		if not is-null-or-empty messages
			promises = messages |> map (message) -> new Promise (resolve, reject) ->
				User.find-by-id message.otherparty-id, (, otherparty) ->
					message .= to-object!
					message.user = otherparty
					resolve message
			Promise.all promises .then (serialized-messages) ->
				done serialized-messages
		else
			done null

	function done(messages)
		res.display req, res, 'i-talks' do
			messages: messages