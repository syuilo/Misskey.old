require! {
	'../../../models/application': Application
	'../../../models/sauth-authentication-session-key': SAuthAuthenticationSessionKey
	'../../../models/user': User
}

module.exports = (req, res) ->
	session-key = req.params.session-key
	is-login = req.session? && req.session.user-id?
	
	(err, key) <- SAuthAuthenticationSessionKey.find-one {key: session-key}
	if key?
		if not key.is-invalid
			if is-login
				(, user) <- User.find-by-id req.session.user-id
				display user
			else
				display null
		else
			res.render 'authorize-invalid-session-key'
	else
		res.render 'authorize-invalid-session-key'

	function display(user)
		(err, app) <- Application.find-by-id key.app-id
		res.render 'authorize' do
			app: app
			is-login: is-login
			me: user
			session-key: session-key
