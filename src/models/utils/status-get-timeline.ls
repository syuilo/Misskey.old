require! {
	'../status': Status
	'../user-following': UserFollowing
}

module.exports = (user-id, limit, since-id, max-id, callback) ->
	function query-callback(, statuses)
		callback statuses
	UserFollowing.find { follower-id: user-id }, (, followings) ->
		| followings? =>
			followings-ids = [user-id] ++ (followings |> map (following) -> following.followee-id.to-string!)
			query = switch
				| !since-id? and !max-id? => { user-id: { $in: followings-ids } }
				| since-id? => (user-id: {$in: followings-ids}) `$and` (id: {$gt: since-id})
				| max-id? => (user-id: {$in: followings-ids}) `$and` (id: {$lt: max-id})
			Status
				.find query
				.sort \-createdAt # Desc
				.limit limit
				.exec query-callback
		| _ => callback null
