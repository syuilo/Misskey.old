require! {
	'../models/access-token': AccessToken
	'../models/sauth-request-token':SauthRequestToken
	'../models/sauth-pincode': SauthPinCode
	'../models/application': Application
	'../models/user': User 
	'../web/utils/login': do-login
}
module.exports = (req, res, server) ->
	login = req.session? && req.session.user-id?
	
	request-token = req.query.request_token ? null
	screen-name = req.body.screen_name ? null
	password = req.body.password ? null
	
	if request-token?
		SauthRequestToken.find request-token, (request-token-instance) ->
			if request-token-instance? && !request-token-instance.is-invalid
				Application.find request-token-instance.app-id, (app) ->
					| screen-name? && password? =>
						do-login server, screen-name, password, (user, web-access-token) ->
							validate request-token-instance, user, app
						, render-confirmation
					| login => User.find req.session.user-id, (user) ->
						validate request-token-instance, user, app
					| _ => render-confirmation!
	
	function validate(request-token-instance, user, app)
		if req.body.cancel != null
			request-token-instance
				..is-invalid = true
				..update!
			render-cancel!
		else
			SauthPinCode.create app.id, user.id, (pincode) ->
				| app.callback-url == '' => render-success!
				| _ => res.redirect app.callback-url + '?pincode=' + pincode.code
	
	function render-confirmation
		res.render '../web/views/authorize-confirm' {app, -login, -login-failed}
	
	function render-cancel
		res.render '../web/views/authorize-cancel' {app, +login, me: user}
	
	function render-success
		res.render '../web/views/authorize-success' {app, +login, me: user, code: pincode.code }
