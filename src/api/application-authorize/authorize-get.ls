require! {
	'../../models/sauth-request-token': SauthRequestToken
	'../../models/application': Application
	'../../models/user': User
}
module.exports = (req, res) ->
	login = req.session? && req.session.user-id?
	request-token = req.query.request-token
	switch
	| request-token == null => res.api-error 400 'consumerKey parameter is required :('
	| _ => SauthRequestToken.find request-token, (request-token-instance) ->
		| request-token-instance == null => res.render '../web/views/authorize-invalidToken' {}
		| request-token-instance.is-invalid => res.render '../web/views/authorize-invalidToken' {}
		| _ => Application.find request-token-instance.app-id, (app) ->
			| login => User.find req.session.user-id, (user) ->
				res.render '../web/views/authorize-confirm' do
					login: true
					me: user
					app: app
			| _ => res.render '../web/views/authorize-confirm' {app, -login, -login-failed}
