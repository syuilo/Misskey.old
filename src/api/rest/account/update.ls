require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[name, comment, badge, url, location, bio, tag, color] = get-express-params req, <[ name comment badge url location bio tag color ]>

	user
		..name = name
		..comment = comment
		..badge = badge
		..url = url
		..location = location
		..bio = bio
		..tag = tag
		..color = if color == /#[a-fA-F0-9]{6}/ then color else user.color
		..save! -> res.api-render filter-user-for-response user
