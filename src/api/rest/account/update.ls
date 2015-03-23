require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	params = req.body
	user
		..name = if params.name != null then params.name else ''
		..comment = if params.comment != null then params.comment else ''
		..badge = if params.badge != null then params.badge else ''
		..url = if params.url != null then params.url else ''
		..location = if params.location != null then params.location else ''
		..bio = if params.bio != null then params.bio else ''
		..tag = if params.tag != null then params.tag else ''
		..color = if params.color != null
				then (if params.color.match /#[a-fA-F0-9]{6}/ then params.color else user.color)
				else ''
		..save! -> res.api-render filter-user-for-response user
