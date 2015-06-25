require! {
	fs
	'../../internal/create-status'
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	text = if req.body.text? then req.body.text else ''
	in-reply-to-status-id = req.body\in-reply-to-status-id ? null
	
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
			res.api-error 500 err