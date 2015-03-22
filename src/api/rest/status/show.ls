require! {
	'../../auth': authorize
	'../../../modesl/status': Status
	'../../../utils/status-response-filter'
}
exports = (req, res) -> authorize req, res, (user, app) ->
	| !(status-id = req.query.status_id)? => res.api-error 400 'status_id parameter is required :('
	| _ => Status.findById status_id, (status) ->
		| !status? => res.api-error 404 'Not found that status :('
		| _ => status-response-filter status, (obj) -> res.api-render obj
