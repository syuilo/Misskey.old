require! {
	fs
	'../../internal/create-status'
	'../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[text, in-reply-to-status-id] = get-express-params do
		req, <[ text in-reply-to-status-id ]>
	
	if empty in-reply-to-status-id then in-reply-to-status-id = null
	
	image = null
	if (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image = fs.read-file-sync path
	
	create-status do
		app, user, text, in-reply-to-status-id, image
	.then do
		(status) ->
			res.api-render status.to-object!
		(err) ->
			res.api-error 400 err