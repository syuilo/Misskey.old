require! {
	bcrypt
	'../../../utils/get-express-params'
	'../../../web/utils/login': do-login
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/user-icon': UserIcon
	'../../../models/user-header': UserHeader
	'../../../models/user-wallpaper': UserWallpaper
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
	| color != /#[a-fA-F0-9]{6}/ => res.api-error 400 'color invalid format'
	| _ => exist-screenname screen-name .then (exist) ->
		| exist => res.api-error 500 'This screen name is already used.'
		| _ =>
			salt = bcrypt.gen-salt-sync 14
			hash-password = bcrypt.hash-sync password, salt
			
			user = new User!
				..screen-name = screen-name
				..password = hash-password
				..name = name
				..color = color
				..followings-count = 1
				..followers-count = 1
				
			user.save (err, created-user) ->
				| err? => res.api-error 500 'Sorry, register failed. please try again.'
				| _ =>
					# Init user image documents
					icon = new UserIcon!
						.._id = created-user.id
						..user-id = created-user.id
					header = new UserHeader!
						.._id = created-user.id
						..user-id = created-user.id
					wallpaper = new UserWallpaper!
						.._id = created-user.id
						..user-id = created-user.id
					err, icon-instance <- icon.save
					err, header-instance <- header.save
					err, wallpaper-instance <- wallpaper.save
					err, syuilo <- User.find-by-id '55192d78d82859a1440d6281'
					syuilo.followers-count++
					syuilo.followings-count++
					syuilo.save ->
						do-login req, created-user.screen-name, password, (user) ->
							res.api-render filter-user-for-response created-user
						, ->
							res.send-status 500
