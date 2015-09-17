require! {
	jade
	'../../../../../models/status': Status
	'../utils/serialize-detail-status'
	'../utils/parse-text'
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	status = options.status
	me = req.me
	status-compiler = jade.compile-file "#__dirname/../../views/dynamic-parts/status/normal/status-detail.jade"
	Status.find-by-id status.id, (, status) ->
		serialize-detail-status status, me, (detail-status) ->
			html = status-compiler do
				status: detail-status
				login: me?
				me: me
				text-parser: parse-text
				config: config.public-config
			res.display req, res, \status do
				status: detail-status
				status-html: html
