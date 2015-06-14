require! {
	'../application': Application
	'../user': User
	'../status': Status
	'./status-get-talk': serialize-talk
	'../../config'
}

# Number<user-id> -> Mongo Documents<users>
module.exports = (user-id) ->
