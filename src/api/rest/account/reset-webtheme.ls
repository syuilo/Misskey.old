require! {
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		user.web-theme-id = null
		user.update -> res.api-render user.filt!
