require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[comment] = get-express-params req, <[ comment ]>

	user
		..comment = comment
		..save ->
			res.api-render filter-user-for-response user
