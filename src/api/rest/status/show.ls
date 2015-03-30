require! {
	'../../../models/status': Status
	'../../../models/utils/serialize-status'
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	status-id = req.query\status-id
	if status-id == null
		res.api-error 400 'status-id parameter is required :('
	else
		Status.find-by-id status-id, (, status) ->
			if status == null
				res.api-error 404 'Not found that post :('
			else
				serialize-status status, res.api-render
