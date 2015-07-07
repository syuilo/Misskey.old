require! {
	'../../../../models/bbs-thread': BBSThread
	'../../../internal/delete-bbs-thread-favorite'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[thread-id] = get-express-params req, <[ thread-id ]>

	delete-bbs-thread-favorite do
		app, user, thread-id
	.then do
		(result) ->
			BBSThread.find-by-id thread-id, (, thread) ->
				res.api-render thread.to-object!
		(err) ->
			res.api-error 400 err