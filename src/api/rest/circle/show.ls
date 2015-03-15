require! {
	'../../../models/application': Application
	'../../api-response': APIResponse
	'../../../models/circle': Circle
	'../../../models/user': User
}

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.query.circle_id == null
			res.apiError 400, 'circle_id is required :('
			return
		circle_id = req.query.circle_id
		Circle.find circle_id, (circle) ->
			if circle == null
				res.apiError 404, 'Not found that circle :('
				return
			res.apiRender circle
