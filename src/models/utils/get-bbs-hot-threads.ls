require! {
	'../bbs-thread': BBSThread
}

# Number -> Promise
module.exports = (limit = 8) ->
	BBSThread
		.find {}
		.sort \-watchersCount
		.limit limit
		.exec!