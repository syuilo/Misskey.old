require! {
	'../../internal/create-user-key'
	'../../../utils/get-express-params'
	'../../../models/user': User
}

module.exports = (req, res) ->
	app-key = req.headers['sauth-app-key']
	
	[session-key, pin-code] = get-express-params do
		req, <[ authentication-session-key pin-code ]>
			
	if app-key?
		create-user-key do
			app-key, session-key, pin-code
		.then do
			(user-key) ->
				(err, user) <- User.find-by-id user-key.user-id
				res.api-render {
					user-key: user-key.key
					user: user.to-object!
				}
			(err) ->
				res.api-error 400 err