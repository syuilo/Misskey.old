require! {
	jade
	'../../../../../models/status': Status
	'../../../../../models/user': User
	'../../../../../models/user-following': UserFollowing
	'../../../../../models/utils/user-following-check'
	'../utils/serialize-detail-timeline-status'
	'../utils/parse-text'
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	status = options.status

	me = req.me
	
	function get-me-following-ids
		resolve, reject <- new Promise!
		if me?
			UserFollowing.find {follower-id: me.id} (, me-followings) ->
				if me-followings? and not empty me-followings
					resolve (me-followings |> map (me-following) -> me-following.followee-id.to-string!)
		else
			resolve null
	
	function get-all-users
		resolve, reject <- new Promise!
		Status
			.find {repost-from-status-id: status.id}
			.sort {created-at: \desc}
			.limit 100posts
			.exec (, reposts) ->
				Promise.all (reposts |> map (repost) ->
					resolve, reject <- new Promise!
					User.find-by-id repost.user-id, (, repost-user) ->
						repost-user .= to-object!
						if me?
							user-following-check me.id, repost-user.id .then (is-following) ->
								repost-user.is-following = is-following
								user-following-check repost-user.id, me.id .then (is-follow-me) ->
									repost-user.is-follow-me = is-follow-me
									resolve user
						else
							repost-user.is-following = null
							repost-user.is-follow-me = null
							resolve repost-user)
				.then (users) ->
					resolve users

	function get-all-users-count
		resolve, reject <- new Promise!
		Status.count {repost-from-status-id: status.id} (err, count) ->
			resolve count
			
	function get-you-know-users(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			Status
				.find {repost-from-status-id: status.id} `$and` {user-id: {$in: me-following-ids}}
				.sort {created-at: \desc}
				.limit 100posts
				.exec (, statuses) ->
					Promise.all (statuses |> map (status) ->
						resolve, reject <- new Promise!
						User.find-by-id status.user-id, (, user) ->
							user .= to-object!
							user.is-following = yes
							user-following-check user.id, me.id .then (is-follow-me) ->
								user.is-follow-me = is-follow-me
								resolve user)
					.then (users) ->
						resolve users
		else
			resolve null
	
	function get-you-know-users-count(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			Status.count {repost-from-status-id: status.id} `$and` {user-id: {$in: me-following-ids}} (err, count) ->
				resolve count
		else
			resolve null
	
	function get-you-dont-know-users(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			Status
				.find {repost-from-status-id: status.id} `$and` {user-id: {$nin: me-following-ids}}
				.sort {created-at: \desc}
				.limit 100posts
				.exec (, statuses) ->
					Promise.all (statuses |> map (status) ->
						resolve, reject <- new Promise!
						User.find-by-id status.user-id, (, user) ->
							user .= to-object!
							user.is-following = no
							user-following-check user.id, me.id .then (is-follow-me) ->
								user.is-follow-me = is-follow-me
								resolve user)
					.then (users) ->
						resolve users
		else
			resolve null
	
	function get-you-dont-know-users-count(me-following-ids)
		resolve, reject <- new Promise!
		if me? and me-following-ids?
			Status.count {repost-from-status-id: status.id} `$and` {user-id: {$nin: me-following-ids}} (err, count) ->
				resolve count
		else
			resolve null

	status-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/status/detail/status.jade"
	(, status) <- Status.find-by-id status.id
	serialize-detail-timeline-status status, me, (detail-status) ->
		html = status-compiler do
			status: detail-status
			login: me?
			me: me
			text-parser: parse-text
			config: config.public-config
			
		get-me-following-ids! .then (me-following-ids) ->
			get-all-users! .then (all-users) ->
				get-all-users-count! .then (all-users-count) ->
					get-you-know-users me-following-ids .then (you-know-users) ->
						get-you-know-users-count me-following-ids .then (you-know-users-count) ->
							get-you-dont-know-users me-following-ids .then (you-dont-know-users) ->
								get-you-dont-know-users-count me-following-ids .then (you-dont-know-users-count) ->
									res.display req, res, 'status-reposts' do
										user: user
										all-users: all-users
										all-users-count: all-users-count
										you-know-users: you-know-users
										you-know-users-count: you-know-users-count
										you-dont-know-users: you-dont-know-users
										you-dont-know-users-count: you-dont-know-users-count
										status: detail-status
										status-html: html
