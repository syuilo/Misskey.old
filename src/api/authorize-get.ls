require! {
	'../models/sauth-request-token': SauthRequestToken
	'../models/application': Application
	'../models/user': User
}
module.exports = (req, res) ->
	login = req.session != null && req.session.userId != null
	request-token = req.query.request_token
	if request-token == null
		res.api-error 400 'consumer_key parameter is required :('
	else
		SauthRequestToken.find request-token, (request-token-instance) ->
			switch
				| request-token-instance == null => res.render '../web/views/authorize-invalidToken' {}
				| request-token-instance.is-invalid => res.render '../web/views/authorize-invalidToken' {}
				| _ => Application.find request-token-instance.app-id, (app) ->
					if login
						User.find req.session.user-id, (user) ->
							res.render '../web/views/authorize-confirm' do
								login: true
								me: user
								app: app
					else
						res.render '../web/views/authorize-confirm' do
							login: false
							app: app
							login-failed: false
