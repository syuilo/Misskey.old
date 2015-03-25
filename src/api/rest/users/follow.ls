require! {
	'../../auth': authorize
	'../../../utils/publish-redis-streaming'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/filter-user-for-response'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	user-id = req.body.user_id
	switch
	| !user-id? => res.api-error 400 'user_id parameter is required :('
	| _ => UserFollowing.is-following user.id, user-id, (is-following) ->
			| is-following => res.api-error 400 'This user is already folloing :)'
			| _ => User.find user-id, (target-user) ->
				| !target-user? => res.api-error 404 'User not found...'
				| _ => UserFollowing.create target-user.id, user.id, (following) ->
					stream-obj = 
						type: 'followedMe'
						value: user
					publish-redis-streaming 'userStream:' + target-user.id, JSON.stringify stream-obj
					res.api-render filter-user-for-response target-user
