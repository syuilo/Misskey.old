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
	new Promise (resolve, reject) ->
		status-gets[content] me.id, 30statuses, null, null .then (statuses) ->
			generate-mobile-home-timeline-html statuses, me, (timeline-html) -> resolve timeline-html
	.then (html) -> res.display req, res, 'home' do
		timeline-html: html
