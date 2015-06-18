require! {
	'../../../models/talk-message': TalkMessage
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	TalkMessage.count {otherparty-id: user.id} `$and` {-is-readed} (err, count) ->
		res.api-render count
