require! {
	'./delete-status'
	'./delete-talk-message'
	'../../models/status': Status
	'../../models/user': User
	'../../models/user-following': UserFollowing
}

module.exports = (user-id) ->
	resolve, reject <- new Promise!
	
	
	