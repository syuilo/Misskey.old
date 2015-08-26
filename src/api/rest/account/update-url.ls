require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[url] = get-express-params req, <[ url ]>

	user
		..url = url
		..save ->
			res.api-render user.to-object!
