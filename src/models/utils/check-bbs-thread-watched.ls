require! {
	'../bbs-thread-watch': BBSThreadWatch
	'../../utils/map-promise'
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, thread-id) ->
	BBSThreadWatch.find {user-id} `$and` {thread-id} .limit 1 .exec! |> map-promise (empty) >> (!)
