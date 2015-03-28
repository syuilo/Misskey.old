require! {
	jade
	'./timeline-serialyzer': serialyzer
	'./parse-text'
	'../../config'
}

module.exports = (statuses, viewer, callback) ->
	compiler = jade.compile-file "#__dirname/../views/templates/timeline.jade"
	if statuses?
		serialyzer statuses, viewrer, (timeline) ->
			html = compiler do
				statuses: timeline
				url: config.publicConfig.url
				login: viewer?
				text-parser: parse-text
			callback html
	else
		html = compiler do
			statuses: null
			url: config.publicConfig.url
			login: viewer?
			text-parser: parse-text
		callback html