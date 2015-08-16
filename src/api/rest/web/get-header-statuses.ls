require! {
	'../../../models/notice': Notice
	'../../../models/talk-message': TalkMessage
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	(err, unread-notices-count) <- Notice.count {user-id: user.id} `$and` {-is-read}
	(err, unread-talk-messages-count) <- TalkMessage.count {otherparty-id: user.id} `$and` {-is-readed}
	
	res.api-render {
		unread-notices-count
		unread-talk-messages-count
	}
