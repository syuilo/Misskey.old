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
		.find {followee-id: user.id}
		.sort {created-at: \desc}
		.limit 100users
		.exec (, followings) ->
			Promise.all (followings |> map (following) ->
				resolve, reject <- new Promise!
				User.find-by-id following.followee-id, (, following-user) ->
					following-user .= to-object!
					user-following-check me.id, following-user.id .then (is-following) ->
						following-user.is-following = is-following
						resolve following-user)
			.then (followings) ->
				res.display req, res, \user-followings {
					followings
					user
				}
