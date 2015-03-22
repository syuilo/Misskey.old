require! {
	'../models/user-following': UserFollowing
}

exports = (user-id, callback) -> UserFollowing.count { follower-id: user-id }, (, count) -> callback count