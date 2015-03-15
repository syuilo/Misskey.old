require! {
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		theme-id = req.body.theme_id
		if theme-id == null
			res.api-error 400 'theme_id parameter is required :('
		else
			user.web-theme-id = theme-id
			user.update -> res.api-render user.filt!
