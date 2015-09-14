require! {
	'../../../../models/utils/status-get-mentions'
	'../../utils/generate-mobile-home-timeline-html'
}

module.exports = (req, res) ->
	me = req.me
	status-get-mentions me.id, 20statuses, null, null .then (statuses) ->
		generate-mobile-home-timeline-html statuses, me, (timeline-html) ->
			res.display req, res, 'mobile/i-mentions' do
				timeline-html: timeline-html
