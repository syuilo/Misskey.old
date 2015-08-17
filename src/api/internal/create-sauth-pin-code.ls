require! {
	'../../models/user': User
	'../../models/application': Application
	'../../models/sauth-authentication-session-key': SAuthAuthenticationSessionKey
	'../../models/sauth-pin-code': SAuthPINCode
}

module.exports = (sauth-session, user) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}
	
	(err, app) <- Application.find-by-id sauth-session.app-id
	
	sauth-session.is-invalid = yes
	sauth-session.save ->
		# Generate KEY
		chars = 'abcdefghijklmnopqrstuvwxyz'
		code = ''
		for i from 1 to 8 by 1
			code += chars[Math.floor (Math.random! * chars.length)]

		pin = new SAuthPINCode!
			..app-id = app.id
			..user-id = user.id
			..session-key = sauth-session.key
			..pin-code = code

		pin.save (err, created-pin) ->
			if err
				console.log err
				throw-error \unknown-error null
			else
				resolve created-pin
