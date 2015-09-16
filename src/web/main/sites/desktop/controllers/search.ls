require! {
	'../../../../../models/status': Status
	'../utils/generate-detail-status-timeline-html'
}

module.exports = (req, res) ->
	q = req.query.q
	search-type = req.query.type
	me = req.me
	Promise.all [
		new Promise (resolve, reject) ->
			reg = new RegExp q, \i
			Status
				.find {text: reg}
				.sort \-createdAt
				.limit 30
				.exec (err, statuses) ->
					generate-detail-status-timeline-html statuses, me, (timeline-html) -> resolve timeline-html
		new Promise (resolve, reject) ->
			resolve null
	] .then (results) -> res.display req, res, \search do
		query: q
		search-type: search-type
		statuses-html: results.0
		users: results.1
