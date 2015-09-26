require! {
	jade
	'../../../../../models/status': Status
	'../../../../../models/user': User
	'../utils/serialize-detail-one-status'
	'../utils/parse-text'
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	status = options.status

	me = req.me
	status-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/status/detail-one.jade"
	Status.find-by-id status.id, (, status) ->
		serialize-detail-one-status status, me, (detail-status) ->
			html = status-compiler do
				status: detail-status
				login: me?
				me: me
				text-parser: parse-text
				config: config.public-config
			res.display req, res, 'status' do
				user: user
				status: detail-status
				status-html: html
