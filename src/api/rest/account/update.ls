require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[name, comment, url, location, bio] = get-express-params req, <[ name comment url location bio ]>

	user
		..name = name
		..comment = comment
		..url = url
		..location = location
		..bio = bio
		..save ->
			res.api-render user.to-object!
