require! {
	'../models/user-following': UserFollowing
}

exports = (user-id, limit, since-id, max-id, callback) ->
	function query-callback(err, statuses)
		callback statuses
	UserFollowing.find { follower-id: user-id }, (followings) ->
		| followings? =>
			followings-ids = [user-id] # Get my statuses
			followings.for-each (following) ->
				followings-ids.push following.followee-id.to-string!
			query = switch
				| !since-id? and !max-id? => { user-id: { $in: followings-ids } }
				| since-id? => { $and: [ user-id: { $in: followings-ids }, id: { $gt: since-id } ] }
				| max-id? => { $and: [ user-id: { $in: followings-ids }, id: { $lt: max-id } ] }
			Status
				.find query
				.sort \-created-at # Desc
				.limit limit
				.exec query-callback
		| _ => callback null