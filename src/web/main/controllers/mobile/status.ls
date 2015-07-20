require! {
	'../../../../models/status': Status
	'../../../../models/utils/status-get-timeline'
	'../../../../models/utils/status-get-mentions'
	'../../utils/generate-mobile-status-detail-html'
}

module.exports = (req, res, content = \home) ->
	me = req.me
	Status.find-by-id req.root-status.id, (, status) ->
		generate-mobile-status-detail-html status, me, (html) ->
			res.display req, res, 'mobile/status' do
				status-html: html
