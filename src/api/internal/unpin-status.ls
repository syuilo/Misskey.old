require! {
	'../../utils/publish-redis-streaming'
	'../../models/user': User
	'../../models/status': Status
}

module.exports = (app, user) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	user.pinned-status = null
	err <- user.save
	if err?
		throw-error \user-save-error err
	else
		resolve user
