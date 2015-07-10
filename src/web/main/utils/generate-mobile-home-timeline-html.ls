require! {
	jade
	'./mobile-timeline-serialyzer'
	'./parse-text'
	'../../../config'
}

module.exports = (statuses, viewer, callback) ->
	status-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/status/mobile/status.jade"
	timeline-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/status/mobile/timeline.jade"
	if statuses?
		mobile-timeline-serialyzer statuses, viewer .then (timeline) ->
			console.log timeline
			statuses-htmls = map do
				(status) ->
					status-compiler do
						status: status
						login: viewer?
						me: viewer
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