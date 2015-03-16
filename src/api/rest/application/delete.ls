require! {
	'../../../models/application': Application
	'../../../config': config
}

authorize = require '../../auth'

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if app.id != config.web-client-id
			res.api-error 403 'access is not allowed :('
			return

		if req.body.id == null
			res.api-error 400 'id parameter is required :('
			return
		id = req.body.id
		if id == ''
			res.api-error 400 'id invalid format'
			return

		Application.find id, (app) ->
			if app == null
				res.api-error 404 'Application not found.'
				return
			app.destroy ->
				res.api-render { status: 'success' }
