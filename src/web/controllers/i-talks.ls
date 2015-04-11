require! {
	'../../models/user': User
	'../../models/talk-message': TalkMessage
}
module.exports = (req, res) ->
	res.display req, res, 'i-talks'
