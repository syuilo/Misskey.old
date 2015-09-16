require! {
	'../../../../../models/user': User
	'../../../../../models/user-following': UserFollowing
	'../../../../../models/status': Status
	'../../../../../models/utils/user-following-check'
	'../utils/generate-detail-status-timeline-html'
	'../../../../../config'
}

module.exports = (req, res, page = \home) ->
	user = req.root-user
	me = if req.login then req.me else null

	# Get is following
	get-is-following = new Promise (resolve, reject) ->
		if !req.login
			resolve null
		else
			user-following-check me.id, user.id .then (is-following) ->
				resolve is-following

	# Get is followme
	get-is-followme = new Promise (resolve, reject) ->
		if !req.login
			resolve null
		else
			user-following-check user.id, me.id .then (is-following) ->
				resolve is-following

	is-following <- get-is-following.then
	is-follow-me <- get-is-followme.then

	res.display do
		req
		res
		\widget-user-profile
		{
			user
			is-following
			is-follow-me
		}
