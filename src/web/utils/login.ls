require! {
	express
	bcrypt
	'../../models/access-token': AccessToken
	'../../models/user': User
	'../../models/notice': Notice
	'../../config': config
}

module.exports = (req, screen-name, password, done, fail) ->
	if screen-name === '' || password === ''
		fail!
	else
		User.find-by-screen-name screen-name, (user) ->
			if user == null
				fail!
			else
				db-password = user.password.replace '$2y$', '$2a$'
				bcrypt.compare password, db-password, (err, same) ->
					if same
						AccessToken.find-by-user-id-and-app-id user.id, config.web-client-id, (webAccessToken) ->
							Notice.create config.web-client-id, 'login', 'ログインしました。', user.id, (notice) ->
								req.session
									..user-id = user.id
									..consumer-key = config.web-client-consumer-key
									..access-token = web-access-token.token
									..save -> done user, web-access-token
					else
						fail!
