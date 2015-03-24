require! {
	bcrypt
	'../../../models/access-token': AccessToken
	'../../../config': config
	'../../../web/utils/login': do-login
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/user-image': UserImage
	'../../../models/utils/filter-user-for-response'
}

exports = (req, res) ->
	screen-name = req.body.screen_name
	name = req.body.name
	password = req.body.password
	color = req.body.color

	switch
	| !screen-name? => res.api-error 400 'screen_name parameter is required :('
	| screen-name.match /^[0-9]+$/ || !screen-name.match /^[a-zA-Z0-9_]{4,20}$/ => res.api-error 400 'screen_name invalid format'
	| !name? => res.api-error 400 'name parameter is required :('
	| name == '' => res.api-error 400 'name parameter is required :('
	| !password? => res.api-error 400 'password parameter is required :('
	| password.length < 8 => res.api-error 400 'password invalid format'
	| !color? => res.api-error 400 'color parameter is required :('
	| !color.match /#[a-fA-F0-9]{6}/ => res.api-error 400 'color invalid format'
	| _ => User.find-one {screen-name} (, user) ->
		| !user? => res.api-error 500 'This screen name is already used.'
		| _ =>
			salt = bcrypt.gen-salt-sync 16
			hash-password = bcrypt.hash-sync password, salt
			User.insert { screen-name, password: hash-password, name, color } (err, created-user) ->
				| err? => res.api-error 500 'Sorry, register failed. please try again.'
				| !created-user? => res.api-error 500 'Sorry, register failed. please try again.'
				| _ => UserImage.insert { user-id: created-user.id } (, user-image) ->
					UserFollowing.insert { followee: 1, follower: created-user.id } (, user-following) ->
						UserFollowing.insert { followee: created-user.id, follower: 1} (, user-following) ->
							do-login req, created-user.screen-name, password, (user) ->
								res.api-render filter-user-for-response created-user
							, ->
								res.send-status 500
