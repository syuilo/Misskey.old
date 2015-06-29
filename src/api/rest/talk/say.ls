require! {
	fs
	'../../auth': authorize
	'../../internal/create-talk-message'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[text, otherparty-id] = get-express-params req, <[ text otherparty-id ]>
	
	image = null
	if (Object.keys req.files).length == 1 =>
		path = req.files.image.path
		image = fs.read-file-sync path
	
	create-talk-message do
		app, user, otherparty-id, text, image
	.then do
		(message) ->
			res.api-render message.to-object!
		(err) ->
			res.api-error 400 err
