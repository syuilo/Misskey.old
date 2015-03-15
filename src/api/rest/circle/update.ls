require! {
	'../../api-response': APIResponse
	'../../../models/application': Application
	'../../../models/circle': Circle
	'../../../models/user': User
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.body.circle_id == null
			then res.apiError 400, 'circle_id parameter is required :('
			else Circle.find req.body.circle_id, (circle) ->
				switch
					| circle == null => res.api-error 404 'Not found that circle :('
					| circle.user-id != user.id => res.api-error 403 'That is not your circle :('
					| _ =>
						circle.name = req.body.name if req.body.name != null
						circle.description = req.body.description if req.body.description != null 
						circle.update -> res.api-render circle
