require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[color] = get-express-params req, <[ color ]>

	user
		..color = if color == /^#[a-fA-F0-9]{6}$/ then color else user.color
		..save ->
			res.api-render user.to-object!
