require! {
	'../../../models/status': Status
	'../../../models/utils/serialize-status'
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	status-id = req.query\status-id
	switch
	| !status-id? => res.api-error 400 'status-id parameter is required :('
	| _ => Status.find-by-id status-id, (, status) -> 
		| !status? => res.api-error 404 'Not found that post :('
		| _ => serialize-status status, res.api-render
