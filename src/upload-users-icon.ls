require! {
	'./models/user': User
	'./models/user-icon': UserIcon
	'./utils/register-image': register-image
	'./config'
}

UserIcon.find {} (err, icons) ->
	icons |> each (icon) ->
		User.find-by-id icon.id, (err, user) ->
			register-image user, \user-icon, "#{user.id}.jpg", \jpg, icon.image