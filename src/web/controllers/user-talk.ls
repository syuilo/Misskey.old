require! {
	async
	'../models/application': Application
	'../models/user': User
	'../models/user-following': UserFollowing
	'../models/talk-message': TalkMessage
	'../utils/talk-get-talk'
}

exports = (req, res) ->
	talk-get-talk req.me.id, req.root-user.id, 32messages, null, null, (messages) ->
		
			