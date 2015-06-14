require! {
	jade
	'./timeline-serialyzer'
	'./generate-timeline-status-html'
	'./parse-text'
	'../../config'
}

module.exports = (statuses, viewer, callback) ->
	timeline-compiler = jade.compile-file "#__dirname/../views/templates/status/timeline.jade" {pretty: '  '}
	if statuses?
		timeline-serialyzer statuses, viewer .then (timeline) ->
			Promise.all (timeline |> map (status) ->
				resolve, reject <- new Promise!
				generate-timeline-status-html status, viewer .then (html) ->
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