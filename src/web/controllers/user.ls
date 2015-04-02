require! {
	async
	marked
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../models/status': Status
	'../utils/timeline-generate-html'
	'../../config'
}

module.exports = (req, res, page = \home) ->
	user = req.root-user
	me = if req.login then req.me else null
	async.series do
		[
			# Get statuses count
			(next) ->
				Status.count {user-id: user.id} (, count) ->
					next null count
			
			# Get Followings count
			(next) ->
				UserFollowing.count {follower-id: user.id} (, count) ->
					next null count
			
			# Get Followers count
			(next) ->
				UserFollowing.count {followee-id: user.id} (, count) ->
					next null count
			
			# Get statuses timeline
			(next) -> 
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
				| _ =>
					UserFollowing.find-one {followee-id: user.id, follower-id: me.id} (, following) ->
						next null following?
			
			# Get is followme
			(next) ->
				| !req.login => next null null
				| _ =>
					UserFollowing.find-one {followee-id: me.id, follower-id: user.id} (, following) ->
						next null following?
			
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
										User.find-one {id: following.followee-id} (, user) ->
											map-next null user
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
										User.find-one {id: follower.follower-id} (, user) ->
											map-next null user
									(, users) ->
										next null users
		]
		(, results) ->
			res.display do
				req
				res
				\user
				{
					statuses-count: results.0
					followings-count: results.1
					followers-count: results.2
					timeline-html: results.3
					is-following: results.4
					is-follow-me: results.5
					bio: results.6
					followings: results.7
					followers: results.8
					user
					tags: user.tags
					page
				}