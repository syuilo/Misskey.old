require! {
	'../../internal/create-sauth-authentication-session-key'
}

module.exports = (req, res) ->
	app-key = req.headers['sauth-app-key']
	if app-key?
		create-sauth-authentication-session-key do
			app-key
		.then do
			(sauth-authentication-session-key) ->
				res.api-render {authentication-session-key: sauth-authentication-session-key.key}
			(err) ->
				res.api-error 400 err