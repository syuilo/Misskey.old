import require \prelude-ls

require! {
	bcrypt
	'../../models/user': User
	'../../config'
}

exports = (req, screen-name, password, done, fail) ->
	| any empty, [screen-name, password] => fail!
	| _ => User.find-one {screen-name} (, user) ->
		| !user? => fail!
		| _ =>
			db-password = user.password.replace '$2y$' '$2a$'
			bcrypt.compare password, db-password, (err, same) ->
				| err => fail!
				| !same => fail!
				| _ => req.session
							..user-id = user.id
							..save -> done user
