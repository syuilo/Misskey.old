require! {
	'../../../models/circle': Circle
}
authorize = require '../../auth'
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		name = req.body.name
		screen-name = req.body.screen_name
		description = req.body.description
		switch
			| req.body.name == null => res.api-error 400 'name parameter is required :('
			| req.body.screen_name == null => res.api-error 400 'screen_name parameter is required :('
			| req.body.description == null => res.api-error 400 'description parameter is required :('
			| _ => Circle.exist-screen-name screen-name, (exist) ->
				| exist => res.api-error 400 'That screen name is exist :('
				| _ => Circle.create user.id, name, screen-name, description, (circle) -> res.api-render circle
