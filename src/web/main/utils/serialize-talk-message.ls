require! {
	'../../models/application': Application
	'../../models/user': User
	'../../config'
}

# TalkMessage -> User -> User -> Promise TalkMessage
module.exports = (message, me, otherparty) -> new Promise (resolve, reject) ->
	message .= to-object!
	(, app) <- Application.find-by-id message.app-id
	message.app = app
	message.user = if message.user-id.to-string! == me.id.to-string! then me else otherparty
	message.otherparty = if message.user-id == me.id then otherparty else me
	resolve message