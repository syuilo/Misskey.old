require! {
	'../user-following': UserFollowing
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (follower-id, followee-id) -> UserFollowing.find {follower-id} `$and` {followee-id} .limit 1 .exec! |> map-promise (empty) >> (!)
