require! {
	async
	'../../models/user': User
	'../../models/talk-message': TalkMessage
}
module.exports = (req, res) ->
	TalkMessage.get-recent-messages-in-recent-talks req.me.id, 10, (messages) ->
		async.map messages,
			(message, next) -> User.find message.user-id, (user) ->
				message.user = user
				User.find message.otherparty-id, (user) ->
					message.otherparty = user
					next null message,
			(err, results) -> res.display req, res, 'i-talks', recent-messages: results
