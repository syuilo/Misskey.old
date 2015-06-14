require! {
	'../status': Status
	'../user-following': UserFollowing
}

# ID -> Number -> Number -> Number -> Promise [Status]
module.exports = (user-id, limit, since-cursor, max-cursor) -> new Promise (resolve, reject) ->
	UserFollowing.find {follower-id: user-id} (, followings) ->
		| followings? and not empty followings =>
			following-ids = [user-id] ++ (followings |> map (following) -> following.followee-id.to-string!)
			query = | !since-id? and !max-id? => {user-id: {$in: following-ids}}
				| since-id? => (user-id: {$in: following-ids}) `$and` (cursor: {$gt: since-cursor})
				| max-id?   => (user-id: {$in: following-ids}) `$and` (cursor: {$lt: max-cursor})
			Status
				.find query
				.sort \-createdAt # Desc
				.limit limit
				.exec (, statuses) -> resolve statuses
		| _ => resolve null
