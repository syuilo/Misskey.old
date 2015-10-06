require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[name] = get-express-params req, <[ name ]>
	
	name .= trim!
	
	if name.length > 20
		res.api-error 400 'name is too long'
	else
		user
			..name = name
			..save ->
				res.api-render user.to-object!
