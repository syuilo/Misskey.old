require! {
	'../models/user-following': UserFollowing
}

exports = (follower-id, followee-id, callback) ->
	UserFollowing
		.find { $and: [ { follower-id }, { followee-id } ] }
		.limit 1following
		.exec (, followings) ->
			followings?