require! {
	'../../models/user': User
	'../../models/application': Application
	'../../models/sauth-authentication-session-key': SAuthAuthenticationSessionKey
}

module.exports = (app-key) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}
	
	(err, ap) <- Application.find-one {app-key}
	if ap?
		# Generate KEY
		chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
		key = 'kyoppie.'
		for i from 1 to 32 by 1
			key += chars[Math.floor (Math.random! * chars.length)]

		sauth-authentication-session-key = new SAuthAuthenticationSessionKey!
			..app-id = app.id
			..key = key

		sauth-authentication-session-key.save (err, created-sauth-authentication-session-key) ->
			if err
				console.log err
				throw-error \unknown-error null
			else
				resolve created-sauth-authentication-session-key
	else
		throw-error \invalid-app-key 'Invalid App Key.'