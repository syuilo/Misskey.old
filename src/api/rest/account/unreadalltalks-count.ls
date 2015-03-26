require! {
	'../../../models/talk-message': TalkMessage
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	TalkMessage.get-all-unread-count user.id, (count) -> res.api-render count
