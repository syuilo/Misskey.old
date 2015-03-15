require! {
	'../../api-response': APIResponse
	'../../../models/application': Application
	'../../../models/circle': Circle
	'../../../models/user': User
}

authorize = require('../../auth');

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.body.circle_id == null
			res.apiError 400, 'circle_id parameter is required :(';
			return
		Circle.find req.body.circle_id, (circle) ->
			if circle == null
				res.apiError 404, 'Not found that circle :(';
				return;
			if circle.userId != user.id
				res.apiError 403, 'That is not your circle :('
				return
			if req.body.name != null
				circle.name = req.body.name
			if req.body.description != null
				circle.description = req.body.description
			circle.update () ->
				res.apiRender circle;
