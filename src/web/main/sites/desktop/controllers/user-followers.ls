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
			.find {followee-id: user.id}
			.sort {created-at: \desc}
			.limit 100users
			.exec (, followers) ->
				Promise.all (followers |> map (follower) ->
					resolve, reject <- new Promise!
					User.find-by-id follower.follower-id, (, follower-user) ->
						follower-user .= to-object!
						user-following-check me.id, follower-user.id .then (is-following) ->
							follower-user.is-following = is-following
							user-following-check follower-user.id, me.id .then (is-follow-me) ->
								follower-user.is-follow-me = is-follow-me
								resolve follower-user)
				.then (followers) ->
					resolve followers

	function get-all-count
		resolve, reject <- new Promise!
		UserFollowing.count {followee-id: user.id} (err, c) ->
			resolve c

	function get-you-know(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			UserFollowing
				.find {followee-id: user.id} `$and` {follower-id: {$in: me-following-ids}}
				.sort {created-at: \desc}
				.limit 100users
				.exec (, followers) ->
					Promise.all (followers |> map (follower) ->
						resolve, reject <- new Promise!
						User.find-by-id follower.follower-id, (, follower-user) ->
							follower-user .= to-object!
							follower-user.is-following = yes
							user-following-check follower-user.id, me.id .then (is-follow-me) ->
								follower-user.is-follow-me = is-follow-me
								resolve follower-user)
					.then (followers) ->
						resolve followers
		else
			resolve null

	function get-you-know-count(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			UserFollowing.count {followee-id: user.id} `$and` {follower-id: {$in: me-following-ids}} (err, c) ->
				resolve c
		else
			resolve null

	get-me-following-ids! .then (me-following-ids) ->
		get-all-count! .then (followers-count) ->
			get-all! .then (followers) ->
				get-you-know-count me-following-ids .then (followers-you-know-count) ->
					get-you-know me-following-ids .then (followers-you-know) ->
						res.display req, res, \user-followers {
							followers-count
							followers-you-know-count
							followers
							followers-you-know
							user
							page: \followers
						}
