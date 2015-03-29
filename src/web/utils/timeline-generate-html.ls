require! {
	jade
	'./timeline-serialyzer': serialyzer
	'./parse-text'
	'../../config'
}

module.exports = (statuses, viewer, callback) ->
	status-compiler = jade.compile-file "#__dirname/../views/templates/status/status.jade"
	timeline-compiler = jade.compile-file "#__dirname/../views/templates/status/timeline.jade"
	if statuses?
		serialyzer statuses, viewer, (timeline) ->
			statuses-htmls = map do
				(status) ->
					status-compiler do
						status: status
						login: viewer?
						text-parser: parse-text
						config: config.public-config
				timeline
			html = timeline-compiler do
				statuses: statuses-htmls
				login: viewer?
			callback html
	else
		html = timeline-compiler do
			statuses: null
			login: viewer?
		callback html