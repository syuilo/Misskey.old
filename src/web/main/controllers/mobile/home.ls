require! {
	'../../../../models/utils/status-get-timeline'
	'../../../../models/utils/status-get-mentions'
	'../../../../models/utils/get-new-users'
	'../../../../models/utils/user-following-check'
	'../../utils/generate-home-timeline-html'
}

status-gets =
	home: status-get-timeline
	mention: status-get-mentions

module.exports = (req, res, content = \home) ->
	me = req.me
	Promise.all [
		new Promise (resolve, reject) ->
			status-gets[content] me.id, 30statuses, null, null .then (statuses) ->
				generate-home-timeline-html statuses, me, (timeline-html) -> resolve timeline-html
		new Promise (resolve, reject) ->
			users <- get-new-users 5 .then
			Promise.all (users |> map (user) ->
				new Promise (resolve, reject) ->
					user .= to-object!
					user-following-check me.id, user.id .then (is-following) ->
						user.is-following = is-following
						resolve user)
				.then (res) ->
					resolve res
	] .then (results) -> res.display req, res, 'mobile/home' do
		timeline-html: results.0
		recommendation-users: results.1
