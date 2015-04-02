require! {
	'../application': Application
	'../user': User
	'../../config'
}

# [TalkMessage] -> User -> User -> Promise [TalkMessage]
module.exports = (messages, me, otherparty) ->
	if empty messages
		new Promise (resolve) -> resolve null
	else
		Promise.all (messages |> map (message) ->
			resolve, reject <- new Promise!
			message .= to-object!
			Application.find-by-id message.app-id, (, app) ->
				message.app = app
				message.user = if message.user-id == me.id then me else otherparty
				message.otherparty = if message.user-id == me.id then otherparty else me
				resolve message)