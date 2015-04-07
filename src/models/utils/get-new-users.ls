require! {
	'../user': User
	'../../config'
}

# Number -> Promise
module.exports = (limit = 5) ->
	User
		.find {}
		.sort \-createdAt
		.limit limit
		.exec!