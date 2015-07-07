require! {
	'../../../internal/update-bbs-thread'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[thread-id, title] = get-express-params req, <[ thread-id title ]>
	
	image = null
	if (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image = fs.read-file-sync path

	update-bbs-thread do
		app, user, thread-id, title, image
	.then do
		(thread) ->
			res.api-render thread.to-object!
		(err) ->
			res.api-error 400 err