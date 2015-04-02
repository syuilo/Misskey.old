require! {
	'../status-favorite': StatusFavorite
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, status-id) ->
	promise = StatusFavorite.find {user-id} `$and` {status-id} .limit 1 .exec!
	console.log '#####################'
	console.log promise
	promise.then (x) -> console.log x
	promise = map-promise ((empty) >> (!)), promise
	console.log '***********************'
	console.log promise
	promise.then (x) -> console.log x