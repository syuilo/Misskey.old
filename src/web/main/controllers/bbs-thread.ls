require! {
	'../../../models/bbs-thread': BBSThread
	'../../../models/user': User
	'../../../models/utils/get-bbs-posts'
	'../../../models/utils/check-bbs-thread-favorited'
	'../../../models/utils/check-bbs-thread-watched'
	'../utils/generate-bbs-posts-html'
}
module.exports = (req, res) ->
	thread = req.root-thread
	is-favorited-promise = if req.login then check-bbs-thread-favorited req.user.id, thread.id else new Promise (resolve, reject) -> resolve no
	is-watched-promise = if req.login then check-bbs-thread-watched req.user.id, thread.id else new Promise (resolve, reject) -> resolve no
	is-favorited <- is-favorited-promise.then
	is-watched <- is-watched-promise.then
	get-bbs-posts thread.id, 1000posts .then (posts) ->
		posts .= reverse!
		generate-bbs-posts-html posts, (html) ->
			res.display req, res, 'bbs-thread' do
				thread: thread
				posts-html: html
				is-favorited: is-favorited
				is-watched: is-watched
