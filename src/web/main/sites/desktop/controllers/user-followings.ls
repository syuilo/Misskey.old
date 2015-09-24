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

	function get-me-following-ids
		resolve, reject <- new Promise!
		if me?
			UserFollowing.find {follower-id: me.id} (, me-followings) ->
				if me-followings? and not empty me-followings
					resolve (me-followings |> map (me-following) -> me-following.followee-id.to-string!)
		else
			resolve null

	function get-all
		resolve, reject <- new Promise!
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
				.then (followings) ->
					resolve followings

	function get-all-count
		resolve, reject <- new Promise!
		UserFollowing.count {follower-id: user.id} (err, c) ->
			resolve c

	function get-you-know(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
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
					.then (followings) ->
						resolve followings
		else
			resolve null

	function get-you-know-count(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			UserFollowing.count {follower-id: user.id} `$and` {followee-id: {$in: me-following-ids}} (err, c) ->
				resolve c
		else
			resolve null

	get-me-following-ids! .then (me-following-ids) ->
		get-all-count! .then (followings-count) ->
			get-all! .then (followings) ->
				get-you-know-count me-following-ids .then (followings-you-know-count) ->
					get-you-know me-following-ids .then (followings-you-know) ->
						res.display req, res, \user-followings {
							followings-count
							followings-you-know-count
							followings
							followings-you-know
							user
						}
