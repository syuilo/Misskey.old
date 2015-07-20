require! {
	jade
	'../../../../models/status': Status
	'../../../../models/utils/status-get-timeline'
	'../../../../models/utils/status-get-mentions'
	'../../utils/serialize-mobile-detail-status'
}

module.exports = (req, res, content = \home) ->
	me = req.me
	status-compiler = jade.compile-file "#__dirname/../../views/dynamic-parts/status/mobile/status.jade"
	Status.find-by-id req.root-status.id, (, status) ->
		serialize-mobile-detail-status status, me, (detail-status) ->
			html = status-compiler do
				status: detail-status
				login: me?
				me: me
				text-parser: parse-text
				config: config.public-config
			res.display req, res, 'mobile/status' do
				status: detail-status
				status-html: html
