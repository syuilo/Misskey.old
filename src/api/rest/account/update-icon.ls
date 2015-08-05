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
		img = gm path
		if not all empty, [trim-x, trim-y, trim-w, trim-h]
			img .= crop trim-w, trim-h, trim-x, trim-y
		img .= compress \jpeg
		img .= quality 80
		img.to-buffer \jpeg (err, buffer) ->
			fs.unlink path
			if err?
				console.log err
				res.api-error 500 'error'
			else
				register-image user, \user-icon "#{user.id}.jpg", \jpg, buffer .then ->
					res.api-render 'success'
