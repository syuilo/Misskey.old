require! {
	'../../auth': authorize
	'../../../models/user': User
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[user-id, screen-name] = get-express-params do
		req, <[ user-id screen-name ]>
	
	if not null-or-empty user-id
		user-id .= trim!
		User.find-by-id user-id, (eww, target-user) ->
			| eww? => res.api-error 500 'Something happened'
			| !target-user? => res.api-error 404 'User not found'
			| _ =>
				res.api-render target-user.to-object!
	else if not null-or-empty screen-name
		screen-name .= trim!
		User.find-one {screen-name-lower: screen-name.to-lower-case!}, (eww, target-user) ->
			| eww? => res.api-error 500 'Something happened'
			| !target-user? => res.api-error 404 'User not found'
			| _ =>
				res.api-render target-user.to-object!
	else
		res.api-error 400 'user-id or screen-name is required'
