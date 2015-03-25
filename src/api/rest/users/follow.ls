require! {
	'../../auth': authorize
	'../../../utils/publish-redis-streaming'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/filter-user-for-response'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	target-user-id = req.body.user_id
	switch
	| !user-id? => res.api-error 400 'user_id parameter is required :('
	| _ => UserFollowing.find-one { $and: [{ follower-id: user.id }, { followee-id: target-user-id }] } (, following) ->
			| following? => res.api-error 400 'This user is already folloing :)'
			| _ => User.find-by-id target-user-id, (, target-user) ->
				| !target-user? => res.api-error 404 'User not found...'
				| _ => UserFollowing.insert { follower-id: user.id, followee-id: target-user.id } (, following) ->
					stream-obj = 
						type: 'followedMe'
						value: user
					publish-redis-streaming 'userStream:' + target-user.id, JSON.stringify stream-obj
					res.api-render filter-user-for-response target-user
