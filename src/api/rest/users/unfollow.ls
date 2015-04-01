require! {
	'../../auth': authorize
	'../../../utils/publish-redis-streaming'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/filter-user-for-response'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(target-user-id = req.body\user-id)? => res.api-error 400 'user-id parameter is required :('
	| target-user-id == user.id => res.api-error 400 'This user is you'
	| _ => UserFollowing.find-one {follower-id: user.id} `$and` {followee-id: target-user-id} (, following) ->
			| !following? => res.api-error 400 'This user is already not following :)'
			| _ => User.find-by-id target-user-id, (, target-user) ->
					| !target-user? => res.api-error 404 'User not found...'
					| _ =>
						UserFollowing.remove { follower-id: user.id } `$and` { followee-id: target-user-id } (err) ->
							user
								..followings-count--
								..save
							target-user
								..followers-count--
								..save
							stream-obj = 
								type: \unfollowed-me
								value: user
							publish-redis-streaming "userStream:#{target-user.id}", to-json stream-obj
							res.api-render filter-user-for-response target-user
