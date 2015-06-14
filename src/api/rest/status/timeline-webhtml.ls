require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/status': Status
	'../../../models/utils/status-get-timeline'
	'../../../web/utils/generate-timeline-status-html'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-cursor, max-cursor] = get-express-params req, <[ since-cursor, max-cursor ]>
	status-get-timeline do
		user.id
		30statuses
		if !empty since-cursor then Number since-cursor else null
		if !empty max-cursor then Number max-cursor else null
	.then (statuses) ->
		console.log '>-----'
		console.time \initpromisestimer
		promises = statuses |> map (status) ->
			resolve, reject <- new Promise!
			generate-timeline-status-html status, user .then (html) ->
				console.log 'statushtml generated!'
				resolve html
		console.time-end \initpromisestimer
		console.log '---'
		console.time \promisetimer
		Promise.all promises .then (timeline-html) ->
			console.time-end \promisetimer
			res.api-render timeline-html.join ''
			console.log '<-----'
