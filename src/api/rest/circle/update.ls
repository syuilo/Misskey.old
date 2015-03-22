require! {
	'../../auth': authorize
	'../../../models/circle': Circle
}
exports = (req, res) -> authorize req, res, (user, app) ->
	| !(circle-id = req.body.circle_id)? => res.api-error 400 'circle_id parameter is required :('
	| _ => Circle.find-by-id circle-id, (, circle) ->
		| !circle? => res.api-error 404 'Not found that circle :('
		| circle.user-id != user.id => res.api-error 403 'That is not your circle :('
		| _ => 
			circle
				..name = req.body.name if req.body.name != null
				..description = req.description if req.body.description != null
				..update -> res.api-render circle
