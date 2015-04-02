require! {
	'../../models/sauth-request-token': SauthRequestToken
	'../../models/application': Application
	'../../models/user': User
}
module.exports = (req, res) ->
	login = req.session? && req.session.user-id?
	switch
	| !(request-token = req.query.request-token)? => res.api-error 400 'consumerKey parameter is required :('
	| _ => SauthRequestToken.find request-token, (request-token-instance) ->
		| !request-token-instance? => res.render '../web/views/authorize-invalidToken' {}
		| request-token-instance.is-invalid => res.render '../web/views/authorize-invalidToken' {}
		| _ => Application.find request-token-instance.app-id, (app) ->
			| login => User.find req.session.user-id, (user) ->
				res.render '../web/views/authorize-confirm' {app, +login, me: user}
			| _ => res.render '../web/views/authorize-confirm' {app, -login, -login-failed}
