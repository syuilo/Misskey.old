require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[id] = get-express-params req, <[ id ]>
	
	if empty id then id = null
	if id?
		if id != /^[a-z]+$/
			res.api-error 400 \invalid-id

	user
		..mobile-header-design-id = id
		..save ->
			res.api-render filter-user-for-response user
