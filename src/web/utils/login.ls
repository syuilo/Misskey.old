import require \prelude-ls

require! {
	express
	bcrypt
	'../../models/access-token': AccessToken
	'../../models/user': User
	'../../models/notice': Notice
	'../../config': config
}

exports = (req, screen-name, password, done, fail) ->
	| any empty, [screen-name, password] => fail!
	| _ => User.find-by-screen-name screen-name, (user) ->
		| !user? => fail!
		| _ =>
			db-password = user.password.replace '$2y$' '$2a$'
			bcrypt.compare password, db-password, (err, same) ->
				| !same => fail!
				| _ => AccessToken.find-by-user-id-and-app-id user.id, config.web-client-id, (web-access-token) ->
					Notice.create config.web-client-id, 'login', 'ログインしました。', user.id, (notice) ->
						req.session
							..user-id = user.id
							..consumer-key = config.web-client-consumer-key
							..access-token = web-access-token.token
							..save -> done user, web-access-token
