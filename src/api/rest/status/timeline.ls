require! {
	'../../auth': authorize
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[ since-id, max-id ] = get-express-params req, <[ since-id, max-id ]>
	status-get-timeline user.id, 30, if !empty since-id then since-id else null, if !empty max-id then max-id else null, (statuses) ->
		res.api-render statuses
