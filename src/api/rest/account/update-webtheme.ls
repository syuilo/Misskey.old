require! {
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	theme-id = req.body.theme-id
	if !theme-id?
		res.api-error 400 'themeId parameter is required :('
	else
		user.web-theme-id = theme-id
		user.update -> res.api-render user.filt!
