require! {
	'../models/sauth-request-token': SauthRequestToken
	'../models/application': Application
	'../models/user': User
}
exports = (req, res) ->
	login = req.session? && req.session.userId?
	request-token = req.query.request_token
	swicth
	| request-token == null => res.api-error 400 'consumer_key parameter is required :('
	| _ => SauthRequestToken.find request-token, (request-token-instance) ->
		| request-token-instance == null => res.render '../web/views/authorize-invalidToken' {}
		| request-token-instance.is-invalid => res.render '../web/views/authorize-invalidToken' {}
		| _ => Application.find request-token-instance.app-id, (app) ->
			| login => User.find req.session.user-id, (user) ->
				res.render '../web/views/authorize-confirm' do
					login: true
					me: user
					app: app
			| _ => res.render '../web/views/authorize-confirm' do
				login: false
				app: app
				login-failed: false
