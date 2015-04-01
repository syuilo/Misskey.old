require! {
	'../user': User
	'../../config'
}

# Number -> Promise
module.exports = (limit = 5) ->
	User
		.find {}
		.sort \createdAd
		.limit limit
		.exec!