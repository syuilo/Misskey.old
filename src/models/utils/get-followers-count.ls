require! {
	'../user-following': UserFollowing
}

exports = (user-id, callback) -> UserFollowing.count { followee-id: user-id }, (, count) -> callback count