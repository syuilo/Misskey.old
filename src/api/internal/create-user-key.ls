require! {
	'../../models/user': User
	'../../models/application': Application
	'../../models/user-key': UserKey
	'../../models/sauth-authentication-session-key': SAuthAuthenticationSessionKey
	'../../models/sauth-pin-code': SAuthPINCode
	'./create-notice'
}

module.exports = (app-key, session-key, pin-code) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}
	
	(err, app) <- Application.find-one {app-key}
	(err, session) <- SAuthAuthenticationSessionKey.find-one {key: session-key}
	(err, pin) <- SAuthPINCode.find-one {pin-code}
	
	switch
	| not app? => throw-error \authorize-failed 'Authorize failed. type:himawari'
	| not session? => throw-error \authorize-failed 'Authorize failed. type:sakurako'
	| app.id.to-string! != session.app-id.to-string! => throw-error \authorize-failed 'Authorize failed. type:kyoppie'
	| not pin? => throw-error \authorize-failed 'Authorize failed. type:akari'
	| pin.session-key != session.key => throw-error \authorize-failed 'Authorize failed. type:tinatsu'
	| _ =>
		(err, user) <- User.find-by-id pin.user-id
		
		(err, exist-key) <- UserKey.find-one {user-id: user.id, app-id: app.id}
		# 既にkeyがあったらそれを返す
		if exist-key?
			done session, pin, exist-key
		else
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
					done session, pin, created-user-key
					
					# Create notice
					create-notice null, user-key.user-id, \install-app {
						app-id: app.id
					} .then ->

	function done(session, pin, user-key)
		resolve user-key
		
		session.remove!
		pin.remove!