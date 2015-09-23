require! {
	'../config'
	'../models/user-key': UserKey
	'../models/application': Application
	'../models/user': User
}

module.exports = (app-key, user-key) ->
	resolve, reject <- new Promise!

	(err, app) <- Application.find-one {app-key: app-key}
	if app?
		(err, user-key-instance) <- UserKey.find-one {key: user-key}
		if user-key-instance?
			if user-key-instance.app-id.to-string! == app.id.to-string!
				(err, user) <- User.find-by-id user-key-instance.user-id
				if user?
					resolve user, app
				else
					reject 'User not found'
			else
				reject 'Invalid app-key or user-key'
		else
			reject 'Invalid user-key'
	else
		reject 'Invalid app-key'
