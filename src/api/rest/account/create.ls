module.exports = (req, res) ->
	screen-name = req.body.screen_name
	name = req.body.name
	password = req.body.password
	color = req.body.color

	switch
	| req.body.screen_name == null => res.api-error 400 'screen_name parameter is required :('
	| !validate-screen-name screen-name => res.api-error 400 'screen_name invalid format'
	| req.body.name == null => res.api-error 400 'name parameter is required :('
	| name == '' => res.api-error 400 'name parameter is required :('
	| req.body.password == null => res.api-error 400 'password parameter is required :('
	| req.body.password.length < 8 => res.api-error 400 'password invalid format'
	| req.body.color == null => res.api-error 400 'color parameter is required :('
	| !req.body.color.match /#[a-fA-F0-9]{6}/ => res.api-error 400 'color invalid format'
	| _ =>
		

	function validate-screen-name screen-name
		4 <= screen-name.length && screen-name.length <= 20 && (!screen-name.match /^[0-9]+$/) && (screen-name.match /^[a-zA-Z0-9_]+$/)
