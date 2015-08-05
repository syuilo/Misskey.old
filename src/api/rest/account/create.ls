require! {
	bcrypt
	'../../../utils/get-express-params'
	'../../../utils/login': do-login
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/filter-user-for-response'
	'../../../models/utils/exist-screenname'
	'../../../config'
}

module.exports = (req, res) ->
	[screen-name, name, password, color] = get-express-params req, <[ screen-name name password color ]>

	switch
	| empty screen-name => res.api-error 400 'screen-name is required :('
	| screen-name == /^[0-9]+$/ || screen-name != /^[a-zA-Z0-9_]{4,20}$/ => res.api-error 400 'screen-name invalid format'
	| empty name => res.api-error 400 'name is required :('
	| empty password => res.api-error 400 'password is required :('
	| password.length < 8 => res.api-error 400 'password invalid format'
	| empty color => res.api-error 400 'color is required :('
	| color != /^#[a-fA-F0-9]{6}$/ => res.api-error 400 'color invalid format'
	| _ => exist-screenname screen-name .then (exist) ->
		| exist => res.api-error 500 'This screen name is already used.'
		| _ =>
			salt = bcrypt.gen-salt-sync 14
			hash-password = bcrypt.hash-sync password, salt
			screen-name-lower = screen-name.to-lower-case!

			user = new User!
				..screen-name = screen-name
				..screen-name-lower = screen-name-lower
				..password = hash-password
				..name = name
				..color = color
				..followings-count = 1
				..followers-count = 1

			user.save (err, created-user) ->
				| err? => res.api-error 500 'Sorry, register failed. please try again.'
				| _ =>
					created-user
						..profile-image = "#{created-user.id}.jpg"
						..banner-image = "#{created-user.id}.jpg"
						..wallpaper-image = "#{created-user.id}.jpg"
					created-user.save (err, created-user) ->
						User.find-one {screen-name: \syuilo} (err, syuilo) ->
							if syuilo? and created-user.screen-name-lower != \syuilo
								following = new UserFollowing!
									..follower-id = created-user.id
									..followee-id = syuilo.id
								followingback = new UserFollowing!
									..follower-id = syuilo.id
									..followee-id = created-user.id
								err, following-instance <- following.save
								err, followingback-instance <- followingback.save
								syuilo.followers-count++
								syuilo.followings-count++
								syuilo.save ->
									do-login req, created-user.screen-name, password, (user) ->
										res.api-render filter-user-for-response created-user
									, ->
										res.send-status 500
							else
								do-login req, created-user.screen-name, password, (user) ->
									res.api-render filter-user-for-response created-user
								, ->
									res.send-status 500
