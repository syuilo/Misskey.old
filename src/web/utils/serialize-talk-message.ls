require! {
	'../../models/application': Application
	'../../models/user': User
	'../../config'
}

# TalkMessage -> User -> User -> Promise TalkMessage
module.exports = (message, me, otherparty) ->
	resolve, reject <- new Promise
	message .= to-object!
	(, app) <- Application.find-by-id message.app-id
	message.app = app
	message.user = if message.user-id == me.id then me else otherparty
	message.otherparty = if message.user-id == me.id then otherparty else me
	resolve message