require! {
	async
	'../../models/utils/get-followings-count'
	'../../models/utils/get-followers-count'
	'../../models/utils/status-get-statuses-count'
	'../../models/utils/status-get-timeline'
	'../../models/utils/status-get-mentions'
	'../utils/timeline-generate-html'
}
post-gets =
	home: status-get-timeline
	mention: status-get-mentions

exports = (req, res, content = \home) ->
	me = req.me
	async.series [
		(next) -> status-get-statuses-count me.id, (count) -> next null, count
		(next) -> get-followings-count me.id, (count) -> next null, count
		(next) -> get-followers-count me.id, (count) -> next null, count
		(next) -> post-gets[content] me.id, 30statuses, null, null, (statuses) ->
			timeline-generate-html statuses, me, (timeline-html) -> next null, timeline-html
	], (, results) -> res.display req, res, 'home' do
		statuses-count: results.0
		followings-count: results.1
		followers-count: results.2
		timeline-html: results.3
