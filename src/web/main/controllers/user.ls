require! {
	marked
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../models/status': Status
	'../../models/utils/user-following-check'
	'../utils/timeline-generate-html'
	'../../config'
}

module.exports = (req, res, page = \home) ->
	user = req.root-user
	me = if req.login then req.me else null
	Promise.all [
		# Get statuses timeline (home page only)
		new Promise (resolve, reject) ->
			if page != \home then resolve null
			Status
				.find {user-id: user.id}
				.sort {created-at: \desc}
				.limit 30status
				.exec (, statuses) ->
					timeline-generate-html statuses, me, (html) ->
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

		# Compile bio markdown to html (profile page only)
		new Promise (resolve, reject) ->
			if page != \profile then resolve null
			if !user.bio? then resolve null
			resolve marked user.bio

		# Get followings (followings page only)
		new Promise (resolve, reject) ->
			if page != \followings then resolve null
			UserFollowing
				.find {follower-id: user.id}
				.sort {created-at: \desc}
				.limit 50users
				.exec (, followings) ->
					| !followings? => resolve null
					| _ =>
						Promise.all (followings |> map (following) ->
							resolve, reject <- new Promise!
							User.find-by-id following.followee-id, (, user) ->
								resolve user.to-object!)
						.then (following-users) -> resolve following-users

		# Get followers (followers page only)
		new Promise (resolve, reject) ->
			if page != \followers then resolve null
			UserFollowing
				.find {followee-id: user.id}
				.sort {created-at: \desc}
				.limit 50users
				.exec (, followers) ->
					| !followers? => resolve null
					| _ =>
						Promise.all (followers |> map (follower) ->
							resolve, reject <- new Promise!
							User.find-by-id follower.follower-id, (, user) ->
								resolve user.to-object!)
						.then (follower-users) -> resolve follower-users
	] .then (results) -> res.display do
		req
		res
		\user
		{
			timeline-html: results.0
			is-following: results.1
			is-follow-me: results.2
			bio: results.3
			followings: results.4
			followers: results.5
			user
			tags: user.tags
			page
		}
