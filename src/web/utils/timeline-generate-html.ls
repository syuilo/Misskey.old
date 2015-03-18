require! {
	jade
	'./timeline-serialyzer': serialyzer
	'./textparser': textparser
	'../../config': config
}

exports = (statuses, viewer, callback) ->
	compiler = jade.compile-file __dirname + '/../views/templates/timeline.jade'
	if statuses?
		serialyzer statuses, viewrer, (timeline) ->
			html = compiler do
				statuses: timeline
				url: config.publicConfig.url
				login: viewer?
				parseText: textparser
			callback html
	else
		html = compiler do
			statuses: null
			url: config.publicConfig.url
			login: viewer?
			parseText: textparser
		callback html