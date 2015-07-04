require! {
	'../../../models/bbs-thread': BBSThread
	'../../../models/user': User
	'../../../models/utils/get-bbs-posts'
	'../utils/generate-bbs-posts-html'
}
module.exports = (req, res) ->
	thread = req.root-thread
	get-bbs-posts thread.id, 1000posts .then (posts) ->
		res.display req, res, 'bbs-thread'
