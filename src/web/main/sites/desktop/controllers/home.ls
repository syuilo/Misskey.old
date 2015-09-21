require! {
	'../../../../../models/utils/status-get-timeline'
	'../../../../../models/utils/status-get-mentions'
	'../../../../../models/utils/get-new-users'
	'../../../../../models/utils/user-following-check'
	'../utils/generate-timeline-html'
}

status-gets =
	home: status-get-timeline
	mentions: status-get-mentions

module.exports = (req, res, option) ->
	content = if option.page? then option.page else \home
	customize-mode = if option.customize? then option.customize else no
	me = req.me
	default-layout =
		left: null
		center: <[ timeline ]>
		right: <[ my-status notices donate recommendation-users ]>
	layout = if me.home-layout? then me.home-layout else default-layout
	Promise.all [
		new Promise (resolve, reject) ->
			status-gets[content] me.id, 10statuses, null, null .then (statuses) ->
				generate-timeline-html statuses, me, (timeline-html) -> resolve timeline-html
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
	] .then (results) -> res.display req, res, \home do
		layout: layout
		customize-mode: customize-mode
		timeline-html: results.0
		recommendation-users: results.1
