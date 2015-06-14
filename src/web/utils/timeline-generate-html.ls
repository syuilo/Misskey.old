require! {
	jade
	'./generate-timeline-status-html-callback'
	'./parse-text'
	'../../config'
}

module.exports = (statuses, viewer, callback) ->
	timeline-compiler = jade.compile-file "#__dirname/../views/templates/status/timeline.jade"
	if statuses?
		Promise.all (statuses |> map (status) ->
			resolve, reject <- new Promise!
			generate-timeline-status-html-callback status, viewer, (html) ->
				resolve html)
		.then (statuses-htmls) ->
			html = timeline-compiler do
				statuses: statuses-htmls
				login: viewer?
			callback html
	else
		html = timeline-compiler do
			statuses: null
			login: viewer?
		callback html