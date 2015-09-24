require! {
	moment
	'../../../../../models/user': User
	'../../../../../models/user-following': UserFollowing
	'../../../../../models/utils/user-following-check'
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	me = if req.login then req.me else null

	UserFollowing
		.find {follower-id: user.id}
		.sort {created-at: \desc}
		.limit 100users
		.exec (, followers) ->
			Promise.all (followers |> map (follower) ->
				resolve, reject <- new Promise!
				User.find-by-id follower.followee-id, (, follower-user) ->
					follower-user .= to-object!
					user-following-check me.id, follower-user.id .then (is-following) ->
						follower-user.is-following = is-following
						resolve follower-user)
			.then (followers) ->
				res.display req, res, \user-followers {
					followers
					user
				}
