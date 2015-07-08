require! {
	moment
	'../../../models/user': User
	'../../../models/talk-message': TalkMessage
	'../../../models/talk-history': TalkHistory
	'../../../models/utils/get-talk-history-messages'
}

module.exports = (req, res) ->
	get-talk-history-messages req.me.id .then (messages) ->
		if messages? and messages.length > 0message
			promises = messages |> map (message) -> new Promise (resolve, reject) ->
				message .= to-object!
				message.display-created-at = moment message.created-at .format 'YYYY年M月D日 H時m分s秒'
				if message.otherparty-id.to-string! == req.me.id.to-string!
					User.find-by-id message.user-id, (, otherparty) ->
						message.user = otherparty
						resolve message
				else
					User.find-by-id message.otherparty-id, (, otherparty) ->
						message.user = otherparty
						resolve message
			Promise.all promises .then (serialized-messages) ->
				serialized-messages .= reverse!
				done serialized-messages
		else
			done null

	function done(messages)
		res.display req, res, 'i-talks' do
			messages: messages