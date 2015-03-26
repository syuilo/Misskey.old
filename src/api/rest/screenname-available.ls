require! {
	'../../models/user': User
	'../../models/utils/exist-screenname'
}

module.exports = (req, res) ->
	screen-name = req.query\screen-name ? null
	if screen-name == null || screen-name == ''
		res.api-error 400 'screen-name parameter is required :('
	else
		screen-name -= /^@/
		exist-screenname screen-name .then (exist) -> res.api-render exist
