require! {
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/status': Status
	'../../../models/utils/user-following-check'
	'../utils/generate-detail-status-timeline-html'
	'../../../config'
}

module.exports = (req, res, page = \home) ->
	user = req.root-user
	me = if req.login then req.me else null

	res.display do
		req
		res
		\widget-user-profile
		{
			user
		}
