require! {
	'../../internal/create-user-key'
	'../../../utils/get-express-params'
}

module.exports = (req, res) ->
	app-key = req.headers['sauth-app-key']
	
	[session-key, pin-code] = get-express-params do
		req, <[ session-key pin-code ]>
			
	if app-key?
		create-user-key do
			app-key, session-key, pin-code
		.then do
			(user-key) ->
				res.api-render {
					user-key: user-key.key
				}
			(err) ->
				res.api-error 400 err