require! {
	fs
	'../../auth': authorize
	'../../limitter'
	'../../internal/create-notice'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	limitter user.id, \notice/create, 86400sec, 100post .then do
		->
			process!
		->
			res.api-error 403 'limit'
	
	function process
		[text] = get-express-params do
			req, <[ text ]>

		create-notice do
			app, user.id, \application, {text}
		.then do
			(notice) ->
				res.api-render notice.to-object!
			(err) ->
				res.api-error 400 err