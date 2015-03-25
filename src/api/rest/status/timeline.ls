require! {
	'../../auth': authorize
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	since-id = if req.query.since_id != null then req.query.since_id else null
	max-id = if req.query.max_id != null then req.query.max_id else null
	status-get-timeline user.id, 30, since-id, max-id, (statuses) ->
		res.api-render statuses
