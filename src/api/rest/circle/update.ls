require! {
	'../../../models/application': Application
	'../../../models/circle': Circle
	'../../../models/user': User
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| req.body\circle-id == null => res.api-error 400, 'circle_id parameter is required :('
	| _ => Circle.find req.body.circle_id, (circle) ->
		| circle == null => res.api-error 404 'Not found that circle :('
		| circle.user-id != user.id => res.api-error 403 'That is not your circle :('
		| _ =>
			circle.name = req.body.name if req.body.name != null
			circle.description = req.body.description if req.body.description?
			circle.save (err) -> res.api-render circle
