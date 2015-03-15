require! {
	'../../api-response': APIResponse
	'../../../models/application': Application
	'../../../models/circle': Circle
	'../../../models/user': User
}

authorize = require '../../auth';

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.body.name == null
			res.apiError 400, 'name parameter is required :(';
			return
		name = req.body.name
		if req.body.screen_name == null
			res.apiError 400, 'screen_name parameter is required :('
			return
		screen-name = req.body.screen_name
		if req.body.description == null
			res.apiError 400, 'description parameter is required :('
			return
		description = req.body.description
		Circle.existScreenName screen-name, (exist) ->
			if exist
				res.apiError 400, 'That screen name is exist :('
				return
			Circle.create user.id, name, screen-name, description, (circle) ->
				res.apiRender circle
