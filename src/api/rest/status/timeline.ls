require! {
	'../../auth': authorize
	'../../utils/serialize-status'
	'../../../utils/get-express-params'
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-id, max-id, count] = get-express-params req, <[ since-id max-id count ]>
	if !empty count
		if count > 100
			count = 100
		if count < 1
			count = 1
	status-get-timeline do
		user.id
		30statuses
		if !empty count then count else 30statuses
		if !empty since-id then since-id else null
		if !empty max-id then max-id else null
	.then (statuses) ->
		Promise.all (statuses |> map (status) ->
			resolve, reject <- new Promise!
			serialize-status status, me, (serialized-status) ->
				resolve serialized-status)
		.then (serialized-statuses) ->
			res.api-render statuses