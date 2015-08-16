require! {
	'../../limitter'
	'../../internal/create-application'
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	limitter user.id, \application/create, 86400sec, 5apps .then do
		->
			process!
		->
			res.api-error 403 'limit'
	
	function process
		[name, id, description, callback-url] = get-express-params do
			req, <[ name id description callback-url ]>

		if empty callback-url then callback-url = null

		create-application do
			app, user, name, id, description, callback-url
		.then do
			(app) ->
				res.api-render app.to-object!
			(err) ->
				res.api-error 400 err