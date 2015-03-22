require! {
	async
	'../models/application': Application
	'../models/user': User
	'../models/user-following': UserFollowing
	'../models/talk-message': TalkMessage
	'../utils/talk-get-talk'
	'../utils/user-following-check'
}

exports = (req, res) ->
	me = req.me
	otherparty = req.root-user
	talk-get-talk me.id, otherparty.id, 32messages, null, null, (messages) ->
		user-following-check otherparty-id, me.id, (following-me) ->
			otherparty-messages = messages.filter ->
				this.user-id == otherparty.id
				
			