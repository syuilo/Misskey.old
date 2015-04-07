require! {
	'../user-following': UserFollowing
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (follower-id, followee-id) ->
	UserFollowing.find {followee-id} `$and` {follower-id} .limit 1 .exec! |> map-promise (empty) >> (!)
