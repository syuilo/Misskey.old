require! {
	'../../internal/create-sauth-pin-code'
	'../../../models/application': Application
	'../../../models/sauth-authentication-session-key': SAuthAuthenticationSessionKey
	'../../../models/user': User
}

module.exports = (req, res) ->
	session-key = req.body[\sauth-session-key]
	cancel = req.body[\cancel]
	
	is-login = req.session? && req.session.user-id?
	
	(err, session) <- SAuthAuthenticationSessionKey.find-one {key: session-key}
	if session?
		if not session.is-invalid
			if is-login
				(, user) <- User.find-by-id req.session.user-id
				generate-pin user
			else
				#generate-pin null
		else
			res.render 'authorize-invalid-session-key'
	else
		res.render 'authorize-invalid-session-key'

	function generate-pin(user)
		(err, app) <- Application.find-by-id session.app-id
		
		# PINコード発行
		create-sauth-pin-code do
			session, user
		.then do
			(pin-code) ->
				# Not Webアプリ (PINコード表示)
				if nul-or-empty app.callback-url
					res.render 'authorize-pin' do
						pin-code: pin-code.pin-code
				# Webアプリ (コールバックURLにリダイレクト)
				else
					res.redirect "#{app.callback-url}?pin-code=#{pin-code.pin-code}"
			(err) ->
				res.render 'authorize-unknown-error'