require! {
	'../../models/user': User
	'../../models/utils/exist-screenname'
	'../../utils/get-express-params'
}

module.exports = (req, res) ->
	[screen-name] = get-express-params req, <[ screen-name ]>

	if empty screen-name
	then res.api-error 400 'screen-name parameter is required :('
	else exist-screenname screen-name .then res.api-render
