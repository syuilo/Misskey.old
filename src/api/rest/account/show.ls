require! {
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	res.api-render user.to-object!
