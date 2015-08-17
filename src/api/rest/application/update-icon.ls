require! {
	fs
	'../../internal/update-application-icon'
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[app-id, trim-x, trim-y, trim-w, trim-h] = get-express-params do
		req, <[ app-id trim-x trim-y trim-w trim-h ]>

	image = null
	path = null
	if (Object.keys req.files).length == 1
		path = req.files.image.path
		image = fs.read-file-sync path

		update-application-icon do
			app, user, app-id, image, trim-x, trim-y, trim-w, trim-h
		.then do
			(ap) ->
				fs.unlink path
				res.api-render ap.to-object!
			(err) ->
				fs.unlink path
				res.api-error 400 err
	else
		res.api-render ':)'	