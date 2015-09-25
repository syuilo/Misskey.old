require! {
	marked
	'../../../../../models/user': User
	'../../../../../models/user-following': UserFollowing
	'../../../../../models/status': Status
	'../../../../../models/utils/user-following-check'
	'../utils/generate-home-timeline-html'
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	page = options.page
	
	me = if req.login then req.me else null
	
	Promise.all [
		# Get timeline
		new Promise (resolve, reject) ->
			Status
				.find {user-id: user.id}
				.sort {created-at: \desc}
				.limit 30status
				.exec (, statuses) ->
					generate-home-timeline-html statuses, me, (html) ->
						resolve html

		# Get is following
		new Promise (resolve, reject) ->
			if !req.login then resolve null
			user-following-check me.id, user.id .then (is-following) ->
				resolve is-following

		# Get is followme
		new Promise (resolve, reject) ->
			if !req.login then resolve null
			user-following-check user.id, me.id .then (is-following) ->
				resolve is-following
	] .then (results) -> res.display do
		req
		res
		\user
		{
			timeline-html: results.0
			is-following: results.1
			is-follow-me: results.2
			user
			page
		}
