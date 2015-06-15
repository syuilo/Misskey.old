require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-id, max-id] = get-express-params req, <[ since-id, max-id ]>
	status-get-timeline do
		user.id
		30statuses
		if !empty since-id then since-id else null
		if !empty max-id then max-id else null
	.then (statuses) ->
		res.api-render statuses