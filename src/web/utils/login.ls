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
	| _ => User.find-one {screen-name} (, user) ->
		| !user? => fail!
		| _ =>
			db-password = user.password.replace '$2y$' '$2a$'
			bcrypt.compare password, db-password, (err, same) ->
				| !same => fail!
				| _ => req.session
							..user-id = user.id
							..save -> done user
