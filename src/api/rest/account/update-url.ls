require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[location] = get-express-params req, <[ location ]>

	user
		..url = url
		..save ->
			res.api-render filter-user-for-response user
