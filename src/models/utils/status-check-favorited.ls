require! {
	'../status-favorite': StatusFavorite
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, status-id) -> StatusFavorite.find {user-id} `$and` {status-id} .limit 1 .exec! |> map-promise (empty) >> (!)
