require! {
	'../user-following': UserFollowing
	'../../utils/map-promise'
}

# Number -> Number -> (Promise Boolean -> udefined)
module.exports = (follower-id, followee-id, callback) ->
	UserFollowing.find-one {followee-id} `$and` {follower-id} (err, following) ->
		callback new Promise (on-fulfilled, on-rejected) ->
			if err then on-rejected err
			on-fulfilled following?
