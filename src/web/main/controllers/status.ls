require! {
	jade
	'../../../models/status': Status
	'../../../models/user': User
	'../utils/serialize-status'
	'../utils/parse-text'
	'../../../config'
}

module.exports = (req, res) ->
	me = req.me
	status-compiler = jade.compile-file "#__dirname/../../views/dynamic-parts/status/home/status.jade"
	Status.find-by-id req.root-status.id, (, status) ->
		serialize-status status, me, (detail-status) ->
			html = status-compiler do
				status: detail-status
				login: me?
				me: me
				text-parser: parse-text
				config: config.public-config
			res.display req, res, 'status' do
				status: detail-status
				status-html: html
