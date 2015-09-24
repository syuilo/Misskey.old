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

	function get-all
		UserFollowing
			.find {follower-id: user.id}
			.sort {created-at: \desc}
			.limit 100users
			.exec (, followings) ->
				Promise.all (followings |> map (following) ->
					resolve, reject <- new Promise!
					User.find-by-id following.followee-id, (, following-user) ->
						following-user .= to-object!
						user-following-check me.id, following-user.id .then (is-following) ->
							following-user.is-following = is-following
							user-following-check following-user.id, me.id .then (is-follow-me) ->
								following-user.is-follow-me = is-follow-me
								resolve following-user)

	function get-all-count
		resolve, reject <- new Promise!
		UserFollowing.count {follower-id: user.id} (err, c) ->
			resolve c

	function get-you-know
		if me?
			UserFollowing.find {follower-id: me.id} (, me-followings) ->
				if me-followings? and not empty me-followings
					me-following-ids = (me-followings |> map (me-following) -> me-following.followee-id.to-string!)
					UserFollowing
						.find {follower-id: user.id} `$and` {followee-id: {$in: me-following-ids}}
						.sort {created-at: \desc}
						.limit 100users
						.exec (, followings) ->
							Promise.all (followings |> map (following) ->
								resolve, reject <- new Promise!
								User.find-by-id following.followee-id, (, following-user) ->
									following-user .= to-object!
									following-user.is-following = yes
									user-following-check following-user.id, me.id .then (is-follow-me) ->
										following-user.is-follow-me = is-follow-me
										resolve following-user)
				else
					resolve, reject <- new Promise!
					resolve null
		else
			resolve, reject <- new Promise!
			resolve null

	function get-you-know-count
		resolve, reject <- new Promise!
		UserFollowing.count {follower-id: user.id} `$and` {followee-id: {$in: me-following-ids}} (err, c) ->
			resolve c

	get-all-count .then (followings-count) ->
		get-all .then (followings) ->
			get-you-know-count .then (followings-you-know-count) ->
				get-you-know .then (followings-you-know) ->
					res.display req, res, \user-followings {
						followings-count
						followings-you-know-count
						followings
						followings-you-know
						user
					}
