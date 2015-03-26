require! {
	'../../auth': authorize
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/filter-user-for-response'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	user-id = req.body\user-id
	switch
	| !user-id? => res.api-error 400 'user-id parameter is required :('
	| _ => UserFollowing.find-one ({follower-id: user.id} `$and` {followee-id: target-user-id}) (, following) ->
			| !following? => res.api-error 400 'This user is already not following :)'
			| _ => User.find user-id, (target-user) ->
				UserFollowing.remove { $and: [{ follower-id: user.id }, { followee-id: target-user-id }] } (err) ->
					stream-obj = 
						type: \unfollowed-me
						value: user
					Streamer.publish "userStream:#{target-user.id}", to-json stream-obj
					res.api-render filter-user-for-response target-user
