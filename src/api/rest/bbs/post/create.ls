require! {
	fs
	'../../../internal/create-bbs-post'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[thread-id, text] = get-express-params req, <[ thread-id text ]>
	
	image = null
	if (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image = fs.read-file-sync path

	create-bbs-post do
		app, user, thread-id, text, image
	.then do
		(post) ->
			res.api-render post.to-object!
		(err) ->
			res.api-error 400 err