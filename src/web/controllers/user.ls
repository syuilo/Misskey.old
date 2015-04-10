require! {
	async
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
	async.series do
		[
			# Get statuses timeline (home page only)
			(next) ->
				| page != \home => next null null
				| _ =>
					Status
						.find {user-id: user.id}
						.sort {created-at: \desc}
						.limit 30status
						.exec (, statuses) ->
							timeline-generate-html statuses, req.me, (html) ->
								next null html

			# Get is following
			(next) ->
				| !req.login => next null null
				| _ => user-following-check me.id, user.id .then (is-following) ->
						next null is-following

			# Get is followme
			(next) ->
				| !req.login => next null null
				| _ => user-following-check user.id, me.id .then (is-following) ->
						next null is-following

			# Compile bio markdown to html
			(next) ->
				| !user.bio? => next null null
				| _ => next null marked user.bio

			# Get followings (followings page only)
			(next) ->
				| page != \followings => next null null
				| _ =>
					UserFollowing
						.find {follower-id: user.id}
						.sort {created-at: \desc}
						.limit 50users
						.exec (, followings) ->
							| !followings? => next null null
							| _ =>
								async.map do
									followings
									(following, map-next) ->
										User.find-by-id following.followee-id, (, user) ->
											map-next null user.to-object!
									(, users) ->
										next null users

			# Get followers (followers page only)
			(next) ->
				| page != \followers => next null null
				| _ =>
					UserFollowing
						.find {followee-id: user.id}
						.sort {created-at: \desc}
						.limit 50users
						.exec (, followers) ->
							| !followers? => next null null
							| _ =>
								async.map do
									followers
									(follower, map-next) ->
										User.find-by-id follower.follower-id, (, user) ->
											map-next null user.to-object!
									(, users) ->
										next null users
		]
		(, results) ->
			res.display do
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
