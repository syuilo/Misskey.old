require! {
	'../../utils/publish-redis-streaming'
	'../../models/user': User
	'../../models/status': Status
}

module.exports = (app, user, status-id) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	if null-or-empty status-id
		throw-error \empty-status-id 'Empty status-id.'
	else
		(err, status) <- Status.find-by-id status-id
		switch
		| err? => throw-error \status-find-error err
		| !status? => throw-error \status-not-found 'Status not found.'
		| _ =>
			user.pinned-status = status.id
			err <- user.save
			if err?
				throw-error \user-save-error err
			else
				resolve status
