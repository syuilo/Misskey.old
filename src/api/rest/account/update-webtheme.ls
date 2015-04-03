require! {
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[theme-id] = get-express-params req, <[ theme-id ]>
	switch
	| empty theme-id => res.api-error 400 'theme-id parameter is required :('
	| _ => 
		user.web-theme-id = theme-id
		user.update -> res.api-render user.filt!
