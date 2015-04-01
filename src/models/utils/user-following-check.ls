require! {
	'../user-following': UserFollowing
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (follower-id, followee-id) ->
	UserFollowing.find-one {followee-id} `$and` {follower-id} (err, following) ->
		new Promise (on-fulfilled, on-rejected) ->
			if err then on-rejected err
			on-fulfilled following?
