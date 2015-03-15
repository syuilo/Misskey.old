require! {
	'../../../models/application': Application
	'../../api-response': APIResponse
	'../../../models/circle': Circle
	'../../../models/user': User
}

authorize = require '../../auth'

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		circle-id = req.query.circle_id
		if circle-id == null
			then res.api-error 400 'circle_id is required :('
			else Circle.find circle_id, (circle) ->
				if circle == null
					then res.api-error 404 'Not found that circle :('
					else res.api-render circle
