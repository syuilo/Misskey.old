require! {
	'../../auth': authorize
	'../../../models/user': User
}

exports = (req, res) ->
	authorize req, res, (user, app) ->
		user-id = req.body.user_id
		switch
		| !user-id? => res.api-error 400 'user_id parameter is required :('
		| _ => User.find user-id, (target-user) ->
			| !target-user? => res.api-error 404 'User not found..'
			| _ =>
				res.api-render target-user.filt!
