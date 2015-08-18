require! {
	'../config'
	'../utils/get-express-params'
	'../models/user-key': UserKey
	'../models/application': Application
	'../models/user': User
	'../utils/is-null'
}

module.exports = (req, res, success) ->
	sauth-app-key = req.headers['sauth-app-key']
	sauth-user-key = req.headers['sauth-user-key']
	
	if (not null-or-empty sauth-app-key) and (not null-or-empty sauth-user-key)
		(err, app) <- Application.find-one {app-key: sauth-app-key}
		if app?
			(err, key) <- UserKey.find-one {key: sauth-user-key}
			if key?
				if key.app-id.to-string! == app.id.to-string!
					(err, user) <- User.find-by-id key.user-id
					if user?
						success user, app
					else
						res.api-error 401 'SAuth failed: User not found'
				else
					res.api-error 401 'SAuth failed: Invalid user-key'
			else
				res.api-error 401 'SAuth failed: Invalid user-key'
		else
			res.api-error 401 'SAuth failed: Invalid app-key'
	else
		is-logged = req.session? && req.session.user-id?
		referer = req.header \Referer
		switch
		| null-or-empty referer => res.api-error 401 'refer is empty'
		| not is-logged => res.api-error 401 'not logged'
		| (req.header\Referer == //^#{config.public-config.url}//) => res.api-error 401 'invalid request'
		| _ =>
			(, user) <- User.find-by-id req.session.user-id
			success user, null
