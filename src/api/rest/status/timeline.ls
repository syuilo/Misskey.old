require! {
	'../../auth': authorize
	'../../utils/serialize-status'
	'../../../utils/get-express-params'
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-cursor, max-cursor, count] = get-express-params req, <[ since-cursor max-cursor count ]>
	if !empty count
		if count > 100
			count = 100
		if count < 1
			count = 1
	status-get-timeline do
		user.id
		if !empty count then count else 20statuses
		if !empty since-cursor then since-cursor else null
		if !empty max-cursor then max-cursor else null
	.then (statuses) ->
		Promise.all (statuses |> map (status) ->
			resolve, reject <- new Promise!
			serialize-status status, user, (serialized-status) ->
				resolve serialized-status)
		.then (serialized-statuses) ->
			res.api-render serialized-statuses