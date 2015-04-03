require! {
	'../../auth': authorize
	'../../../models/application': Application
	'../../../config'
	'../../../utils/get-express-params'
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[id] = get-express-params req, <[ id ]>
	switch
	| app.id != config.web-client-id => res.api-error 403 'access is not allowed :('
	| empty id => res.api-error 400 'id parameter is required :('
	| _ => Application.find id, (app) ->
		| !app? => res.api-error 404 'Application not found.'
		| _ => app.destroy -> res.api-render status: 'success'
