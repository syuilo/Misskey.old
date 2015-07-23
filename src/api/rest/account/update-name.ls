require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[name] = get-express-params req, <[ name ]>

	user
		..name = name
		..save ->
			res.api-render filter-user-for-response user
