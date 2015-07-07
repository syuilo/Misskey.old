require! {
	'../../../../models/bbs-thread': BBSThread
	'../../../internal/create-bbs-thread-watch'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[thread-id] = get-express-params req, <[ thread-id ]>

	create-bbs-thread-watch do
		app, user, thread-id
	.then do
		(watch) ->
			BBSThread.find-by-id thread-id, (, thread) ->
				res.api-render thread.to-object!
		(err) ->
			res.api-error 400 err