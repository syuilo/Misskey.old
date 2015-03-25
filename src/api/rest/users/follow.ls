require! {
	'../../auth': authorize
	'../../../utils/publish-redis-streaming'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/filter-user-for-response'
	'../../../models/utils/user-following-check'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	user-id = req.body.user_id
	switch
	| !user-id? => res.api-error 400 'user_id parameter is required :('
	| _ => user-following-check user.id, user-id, (is-following) ->
			| is-following => res.api-error 400 'This user is already folloing :)'
			| _ => User.find-by-id user-id, (, target-user) ->
				| !target-user? => res.api-error 404 'User not found...'
				| _ => UserFollowing.insert { follower-id: user.id, followee-id: target-user.id } (, following) ->
					stream-obj = 
						type: 'followedMe'
						value: user
					publish-redis-streaming 'userStream:' + target-user.id, JSON.stringify stream-obj
					res.api-render filter-user-for-response target-user
