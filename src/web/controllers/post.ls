require! {
	'../../models/status': Status
	'../../models/user': User
}
module.exports = (req, res) ->
	res.display req, res, 'status'
