require! {
	'../../../../models/utils/status-get-timeline'
	'../../utils/generate-mobile-home-timeline-html'
}

module.exports = (req, res) ->
	me = req.me
	status-get-timeline me.id, 20statuses, null, null .then (statuses) ->
		generate-mobile-home-timeline-html statuses, me, (timeline-html) ->
			res.display req, res, 'mobile/home' do
				timeline-html: timeline-html
