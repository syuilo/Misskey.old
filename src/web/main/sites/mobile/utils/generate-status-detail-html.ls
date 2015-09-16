require! {
	jade
	'./serialize-detail-status'
	'./parse-text'
	'../../../../../config'
}

module.exports = (status, viewer, callback) ->
	status-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/status/normal/status-detail.jade"
	if status?
		serialize-detail-status status, viewer, (detail-status) ->
			html = status-compiler do
				status: detail-status
				login: viewer?
				me: viewer
				text-parser: parse-text
				config: config.public-config
			callback html
	else
		callback null
