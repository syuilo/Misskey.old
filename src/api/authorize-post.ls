require! {
	'../models/access-token': AccessToken
	'../models/sauth-request-token':SauthRequestToken
	'../models/sauth-pincode': SauthPinCode
	'../models/application': Application
	'../models/user': User 
	'../web/utils/login': do-login
}
module.exports = (req, res, server) ->
	login = req.session != null && req.session.user-id != null
	
	request-token = typeof req.query.request_token != \undefined ? req.query.request_token : null
	screen-name = typeof req.body.screen_name != \undefined ? req.body.screen_name : null
	password = typeof req.body.password != \undefined ? req.body.password : null
	
	if request-token != null
		SauthRequestToken.find request-token, (request-token-instance) ->
			if request-token-instance != null && !request-token-instance.is-invalid
				Application.find request-token-instance.app-id, (app) ->
					if screen-name != null && password != null
						do-login server, screen-name, password, (user, web-access-token) ->
							validate request-token-instance, user, app
						, render-confirmation
					else if login
						User.find req.session.user-id, (user) ->
							validate request-token-instance, user, app
					else
						render-confirmation!
	
	
	function validate(request-token-instance, user, app)
		if req.body.cancel != null
			request-token-instance
				..is-invalid = true
				..update!
			render-cancel!
		else
			SauthPinCode.create app.id, user.id, (pincode) ->
				if app.callback-url == ''
					render-success!
				else
					res.redirect app.callback-url + '?pincode=' + pincode.code
	
	function render-confirmation
		res.render '../web/views/authorize-confirm' do
			login: false
			app: app
			login-failed: false

	function render-cancel
		res.render '../web/views/authorize-cancel' do
			login: true
			app: app
			me: user
	
	function render-success
		res.render '../web/views/authorize-success' do
			login: true
			me: user
			app: app
			code: pincode.code
