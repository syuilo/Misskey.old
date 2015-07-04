require! {
	'../../../models/bbs-thread': BBSThread
	'../../../models/user': User
}
module.exports = (req, res) ->
	res.display req, res, 'bbs-thread'
