require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
	'../../../utils/publish-redis-streaming'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[target-user-id] = get-express-params req, <[ target-user-id ]>
	| empty target-user-id => res.api-error 400 'user-id parameter is required :('
	| target-user-id == user.id => res.api-error 400 'This user is you'
	| _ => UserFollowing.find-one {follower-id: user.id} `$and` {followee-id: target-user-id} (, following) ->
			| following? => res.api-error 400 'This user is already folloing :)'
			| _ => User.find-by-id target-user-id, (, target-user) ->
					| !target-user? => res.api-error 404 'User not found...'
					| _ =>
						following = new UserFollowing do
							follower-id: user.id
							followee-id: target-user.id
						following.save (, created-following) ->
							(, count) <- UserFollowing.count {follower-id: user.id}
							user
								..followings-count = count
								..save!
							(, count) <- UserFollowing.count {followee-id: target-user.id}
							target-user
								..followers-count = count
								..save!
							stream-obj = 
								type: \followed-me
								value: user
							publish-redis-streaming "userStream:#{target-user.id}", to-json stream-obj
							res.api-render filter-user-for-response target-user
