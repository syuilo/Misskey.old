require! {
	moment
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
	option = if option? then option else {}
	content = if option.page? then option.page else \home
	customize-mode = if option.customize? then option.customize else no
	me = req.me
	widgets = <[ timeline my-status notices recommendation-users donate big-analog-clock small-analog-clock big-calendar small-calendar ]>
	default-layout =
		left: <[]>
		center: <[ timeline ]>
		right: <[ my-status notices recommendation-users donate ]>
	layout = if me.home-layout? then me.home-layout else default-layout
	use-widgets = layout.left.concat layout.center.concat layout.right
	unuse-widgets = widgets |> map (widget) ->
		if (use-widgets.index-of widget) == -1
			widget
	Promise.all [
		new Promise (resolve, reject) ->
			if customize-mode or (use-widgets.index-of \timeline) > -1
				status-gets[content] me.id, 10statuses, null, null .then (statuses) ->
					generate-timeline-html statuses, me, (timeline-html) -> resolve timeline-html
			else
				resolve null
		new Promise (resolve, reject) ->
			if customize-mode or (use-widgets.index-of \recommendation-users) > -1
				users <- get-new-users 5 .then
				Promise.all (users |> map (user) ->
					new Promise (resolve, reject) ->
						user .= to-object!
						user-following-check me.id, user.id .then (is-following) ->
							user.is-following = is-following
							resolve user)
					.then (res) ->
						resolve res
			else
				resolve null
	] .then (results) -> res.display req, res, \home do
		layout: layout
		unuse-widgets: unuse-widgets
		moment: moment
		customize-mode: customize-mode
		timeline-html: results.0
		recommendation-users: results.1
