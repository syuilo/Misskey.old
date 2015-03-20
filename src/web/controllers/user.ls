require! {
	async
	marked
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../models/status': Status
	'../utils/timeline': 
	'../../config'
}

exports = (req, res, content-type = \home) ->
	async.series do
		[
			# Get statuses count
			(next) ->
				Status.count { user-id: req.root-user.id } (err, count) ->
					next null count