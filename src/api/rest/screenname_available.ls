require! {
	'../../models/user': User
}
module.exports = (req, res) ->
	screen-name = req.query.screen_name
	if screen-name == null || screen_name == ''
		res.api-error 400 'screen_name parameter is required :('
	else
		screen-name .= replace /^@/ ''
		User.find-by-screen-name screen-name, (user) -> res.api-render user != null
