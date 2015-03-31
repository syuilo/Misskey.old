require! {
	'../status-favorite': StatusFavorite
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, status-id) ->
	console.log (StatusFavorite.find {user-id} `$and` {status-id} .limit 1 .exec!)
	StatusFavorite.find {user-id} `$and` {status-id} .limit 1 .exec! |> map-promise (empty) >> (!)
