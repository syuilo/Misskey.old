require! {
	'../../models/user': User
	'../../models/application': Application
	'../../models/user-key': UserKey
	'../../models/sauth-authentication-session-key': SAuthAuthenticationSessionKey
	'../../models/sauth-pin-code': SAuthPINCode
}

module.exports = (app-key, session-key, pin-code) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}
	
	(err, app) <- Application.find-one {app-key}
	(err, session) <- SAuthAuthenticationSessionKey.find-one {key: session-key}
	(err, pin) <- SAuthPINCode.find-one {pin-code}
	
	switch
	| not app? => throw-error \authorize-failed 'Authorize failed.'
	| not session? => throw-error \authorize-failed 'Authorize failed.'
	| app.id.to-string! != session.app-id.to-string! => throw-error \authorize-failed 'Authorize failed.'
	| session.is-invalid? => throw-error \authorize-failed 'Authorize failed.'
	| not pin? => throw-error \authorize-failed 'Authorize failed.'
	| pin.session-key != session.key => throw-error \authorize-failed 'Authorize failed.'
	| _ =>
		(err, user) <- User.find-by-id pin.user-id
		
		# Generate KEY
		chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-'
		user-key-token = 'yryr.'
		for i from 1 to 32 by 1
			user-key-token += chars[Math.floor (Math.random! * chars.length)]

		user-key = new UserKey!
			..app-id = app.id
			..user-id = user.id
			..key = user-key-token

		user-key.save (err, created-user-key) ->
			if err
				console.log err
				throw-error \unknown-error null
			else
				session.remove!
				pin.remove!
				resolve created-user-key
