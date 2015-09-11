require! {
	'../config'
	'../utils/get-express-params'
	'../models/user-key': UserKey
	'../models/application': Application
	'../models/user': User
	'../utils/is-null'
}

module.exports = (req, res, success, not-login-handler = null) ->
	sauth-app-key = req.headers['sauth-app-key']
	sauth-user-key = req.headers['sauth-user-key']

	function omg(code, msg)
		res.api-error code, msg

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
						omg 401 'SAuth failed: User not found'
				else
					omg 401 'SAuth failed: Invalid user-key'
			else
				omg 401 'SAuth failed: Invalid user-key'
		else
			omg 401 'SAuth failed: Invalid app-key'
	else
		is-logged = req.session? && req.session.user-id?
		referer = req.header \Referer
		switch
		| null-or-empty referer => omg 401 'refer is empty'
		| not is-logged =>
			if not-login-handler?
				not-login-handler!
			else
				omg 401 'not logged'
		| (req.header\Referer == //^#{config.public-config.url}//) => omg 401 'invalid request'
		| _ =>
			(, user) <- User.find-by-id req.session.user-id
			success user, null
