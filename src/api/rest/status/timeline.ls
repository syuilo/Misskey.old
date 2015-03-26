require! {
	'../../auth': authorize
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	since-id = req.query\since-id ? null
	max-id = req.query\max-id ? null
	status-get-timeline user.id, 30, since-id, max-id, (statuses) ->
		res.api-render statuses
