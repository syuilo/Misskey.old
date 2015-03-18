require! {
	bcrypt
	'../../../models/access-token': AccessToken
	'../../../config': config
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/user-image': UserImage
}

do-login = require '../../../web/utils/login'

module.exports = (req, res) ->
	screen-name = req.body.screen_name
	name = req.body.name
	password = req.body.password
	color = req.body.color

	switch
	| req.body.screen_name == null => res.api-error 400 'screen_name parameter is required :('
	| screen-name < 4 || 20 < screen-name || screen-name.match /^[0-9]+$/ || !screen-name.match /^[a-zA-Z0-9_]+$/ => res.api-error 400 'screen_name invalid format'
	| req.body.name == null => res.api-error 400 'name parameter is required :('
	| name == '' => res.api-error 400 'name parameter is required :('
	| req.body.password == null => res.api-error 400 'password parameter is required :('
	| req.body.password.length < 8 => res.api-error 400 'password invalid format'
	| req.body.color == null => res.api-error 400 'color parameter is required :('
	| !req.body.color.match /#[a-fA-F0-9]{6}/ => res.api-error 400 'color invalid format'
	| _ => User.find-by-screen-name screen-name, (user) ->
		| !user? => res.api-error 500 'This screen name is already used.'
		| _ =>
			salt = bcrypt.gen-salt-sync 16
			hash-password = bcrypt.hash-sync password, salt
			User.create screen-name, hash-password, name, color, (created-user) ->
				| created-user == null => res.api-error 500 'Sorry, register failed. please try again.'
				| _ => UserImage.create created-user.id, (user-image) ->
					AccessToken.create config.web-client-id, created-user.id, (access-token) ->
						UserFollowing.create 1, created-user.id, 1, (user-following) ->
							UserFollowing.create created-user.id, 1, (user-following) ->
								do-login req, created-user.screen-name, password, (user, web-access-token) ->
									res.api-render created-user.filt!
								, ->
									res.send-status 500
