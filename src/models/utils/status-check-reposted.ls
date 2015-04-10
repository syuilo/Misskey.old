require! {
	'../status': Status
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, status-id) ->
	Status.find {user-id} `$and` {repost-from-status-id: status-id} .limit 1 .exec! |> map-promise (empty) >> (!)
