require! {
	jade
	'./serialize-timeline-status'
	'./parse-text'
	'../../config'
}

module.exports = (status, viewer) -> new Promise (resolve, reject) ->
	status-compiler = jade.compile-file "#__dirname/../views/templates/status/status.jade"
	serialize-timeline-status status, viewer, (serialized-status) ->
		html = status-compiler do
			status: serialized-status
			login: viewer?
			me: viewer
			text-parser: parse-text
			config: config.public-config
		resolve html
