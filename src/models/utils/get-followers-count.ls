require! {
	'../user-following': UserFollowing
}

exports = (user-id) ->
	resove, reject <- new Promise!
	err, count <- UserFollowing.count {followee-id: user-id}
	if err?
		then reject err
		else resolve count
