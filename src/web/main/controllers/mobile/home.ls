require! {
	'../../../../models/utils/status-get-timeline'
	'../../../../models/utils/status-get-mentions'
	'../../utils/generate-mobile-home-timeline-html'
}

status-gets =
	home: status-get-timeline
	mention: status-get-mentions

module.exports = (req, res, content = \home) ->
	me = req.me
	status-gets[content] me.id, 20statuses, null, null .then (statuses) ->
		generate-mobile-home-timeline-html statuses, me, (timeline-html) ->
			res.display req, res, 'mobile/home' do
				timeline-html: timeline-html
