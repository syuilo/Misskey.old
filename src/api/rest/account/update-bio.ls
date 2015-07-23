require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[bio] = get-express-params req, <[ bio ]>

	user
		..bio = bio
		..save ->
			res.api-render filter-user-for-response user
