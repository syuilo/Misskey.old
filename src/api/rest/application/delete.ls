require! {
	'../../../models/application': Application
	'../../../config'
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| app.id != config.web-client-id => res.api-error 403 'access is not allowed :('
	| !(id = req.body.id)? => res.api-error 400 'id parameter is required :('
	| empty id => res.api-error 400 'id invalid format'
	| _ => Application.find id, (app) ->
		| !app? => res.api-error 404 'Application not found.'
		| _ => app.destroy -> res.api-render status: 'success'
