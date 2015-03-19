require! {
	'../../auth': authorize
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
}

exports = (req, res) ->
	authorize req, res, (user, app) ->
		user-id = req.body.user_id
		switch
		| !user-id? => res.api-error 400 'user_id parameter is required :('
		| _ =>  UserFollowing.find user-id, user.id, (following) ->
			| !following? => res.api-error 400 'This user is already not following :)'
			| _ => User.find user-id, (target-user) ->
				following.destroy ->
					stream-obj = 
						type: 'unfollowedMe'
						value: user.filt!
					Streamer.publish 'userStream:' + target-user.id, JSON.stringify stream-obj
					res.api-render target-user.filt!
