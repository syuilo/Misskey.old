require! {
	fs
	'../../auth': authorize
	'../../limitter'
	'../../internal/create-status'
	'../../utils/serialize-status'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	limitter user.id, \status/update, 86400sec, 500post .then do
		->
			process!
		->
			res.api-error 403 'limit'
	
	function process
		[text, in-reply-to-status-id] = get-express-params do
			req, <[ text in-reply-to-status-id ]>

		if empty in-reply-to-status-id then in-reply-to-status-id = null

		image = null
		path = null
		if (Object.keys req.files).length == 1 =>
			path = req.files.image.path
			image = fs.read-file-sync path

		create-status do
			app, user, text, in-reply-to-status-id, image
		.then do
			(status) ->
				if path? then fs.unlink path
				if status?
					serialize-status status, user, (serialized-status) ->
						res.api-render serialized-status
				else
					res.api-render \ok
			(err) ->
				if path? then fs.unlink path
				res.api-error 400 err