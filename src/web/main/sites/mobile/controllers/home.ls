require! {
	'../../../../../models/utils/status-get-timeline'
	'../utils/generate-home-timeline-html'
}

module.exports = (req, res) ->
	me = req.me
	status-get-timeline me.id, 20statuses, null, null .then (statuses) ->
		generate-home-timeline-html statuses, me, (timeline-html) ->
			res.display req, res, \home do
				timeline-html: timeline-html
