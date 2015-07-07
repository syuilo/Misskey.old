require! {
	'../bbs-thread-favorite': BBSThreadFavorite
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, thread-id) ->
	BBSThreadFavorite.find {user-id} `$and` {thread-id} .limit 1 .exec! |> map-promise (empty) >> (!)
