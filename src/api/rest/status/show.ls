require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/utils/serialize-status'
	'../../../models/status': Status
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[status-id] = get-express-params req, <[ status-id ]>
	switch
	| empty status-id => res.api-error 400 'status-id parameter is required :('
	| _ => Status.find-by-id status-id, (, status) ->
		| !status? => res.api-error 404 'Not found that post :('
		| _ => serialize-status status, res.api-render
