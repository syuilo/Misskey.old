require! {
	'../../../models/bbs-thread': BBSThread
	'../../../models/user': User
}

module.exports = (req, res) ->
	thread = req.root-thread
	res.display req, res, 'bbs-thread-settings' do
		thread: thread
