require! {
	'../../auth': authorize
	'../../../models/circle': Circle
	'../../../utils/circle-exist-screen-name'
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(name = req.body.name)? => res.api-error 400 'name parameter is required :('
	| !(screen-name = req.body.screen_name)? => res.api-error 400 'screen_name parameter is required :('
	| !(description = req.body.description)? => res.api-error 400 'description parameter is required :('
	| _ => circle-exist-screen-name screen-name, (exist) ->
		| exist => res.api-error 400 'That screen name is exist :('
		| _ => Circle.insert { user-id: user.id, name, screen-name, description} (circle) -> res.api-render circle
