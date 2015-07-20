require! {
	jade
	'./serialize-mobile-detail-status'
	'./parse-text'
	'../../../config'
}

module.exports = (status, viewer, callback) ->
	status-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/status/mobile/status.jade"
	if status?
		serialize-mobile-detail-status status, viewer .then (timeline) ->
			html = status-compiler do
				status: status
				login: viewer?
				me: viewer
				text-parser: parse-text
				config: config.public-config
			callback html
	else
		callback null