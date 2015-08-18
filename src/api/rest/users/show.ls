require! {
	'../../auth': authorize
	'../../../models/user': User
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[user-id] = get-express-params do
		req, <[ user-id ]>
	switch
	| null-or-empty user-id => res.api-error 400 'user-id is required'
	| _ => User.find-by-id user-id, (eww, target-user) ->
		| eww? => res.api-error 500 'Something happened'
		| !target-user? => res.api-error 404 'User not found'
		| _ =>
			res.api-render target-user.to-object!
