require! {
	fs
	'../../auth': authorize
	'../../internal/user-unlink-application'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	if not app?
		[app-id] = get-express-params req, <[ app-id ]>

		user-unlink-application do
			app, user, app-id
		.then do
			->
				res.api-render \ok
			(err) ->
				res.api-error 400 err
