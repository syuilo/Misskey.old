require! {
	'../user-following': UserFollowing
}

# Number -> Number -> Promise Boolean
module.exports = (follower-id, followee-id) ->
	resolve, reject <- new Promise!
	
	err, followings <- UserFollowing
		.find {follower-id} `$and` {followee-id}
		.limit 1
		.exec
		
	if err?
		then reject err
		else resolve followings?
