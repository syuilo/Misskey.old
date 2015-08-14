require! {
	fs
	gm
	'../../../utils/register-image'
	'../../../utils/get-express-params'
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[trim-x, trim-y, trim-w, trim-h] = get-express-params req, <[ trim-x trim-y trim-w trim-h ]>
	if (Object.keys req.files).length == 1
		path = req.files.image.path
		(normal-image-buffer) <- generate-normal-image path .then
		(blurred-image-buffer) <- generate-blurred-image path .then
		fs.unlink path
		register-image user, \user-banner "#{user.id}.jpg", \jpg, normal-image-buffer .then (path) ->
			register-image user, \user-banner "#{user.id}-blurred.jpg", \jpg, blurred-image-buffer .then ->
				user.banner-image = path
				user.save ->
					res.api-render 'success'
	else
		res.api-error 400 'Not attached image'

	function generate-normal-image(path)
		resolve, reject <- new Promise!
		image = gm path
		if not all empty, [trim-x, trim-y, trim-w, trim-h]
			image .= crop trim-w, trim-h, trim-x, trim-y
		image .= compress \jpeg
		image .= quality 80
		image.to-buffer \jpeg (, buffer) ->
			resolve buffer
	
	function generate-blurred-image(path)
		resolve, reject <- new Promise!
		image = gm path
		if not all empty, [trim-x, trim-y, trim-w, trim-h]
			image .= crop trim-w, trim-h, trim-x, trim-y
		image .= blur 64, 20
		image .= compress \jpeg
		image .= quality 80
		image.to-buffer \jpeg (, buffer) ->
			resolve buffer
