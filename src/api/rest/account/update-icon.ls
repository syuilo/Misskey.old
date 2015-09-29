require! {
	fs
	gm
	'image-type': image-type
	'../../../utils/register-image'
	'../../../utils/delete-image'
	'../../../utils/get-express-params'
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[trim-x, trim-y, trim-w, trim-h] = get-express-params req, <[ trim-x trim-y trim-w trim-h ]>
	if (Object.keys req.files).length >= 1 and req.files.image
		path = req.files.image.path
		image = fs.read-file-sync path
		fs.unlink path
		
		# Detect the image type
		img-type = (image-type image).ext
		switch (img-type)
		| \gif =>
			if user.is-plus
				update image, \gif
			else
				res.api-error 400 'Denied GIF upload (plus-account only).'
		| _ => 
			img = gm image
			if not all empty, [trim-x, trim-y, trim-w, trim-h]
				img .= crop trim-w, trim-h, trim-x, trim-y
			img .= compress \jpeg
			img .= quality 80
			img.to-buffer \jpeg (err, buffer) ->
				if err?
					console.log err
					res.api-error 500 'error'
				else
					update buffer, \jpg
	else
		res.api-error 400 'Not attached image'

	function update(image, img-type)
		register-image user, \user-icon, "#{user.id}.#{img-type}", img-type, image .then (path) ->
			delete-image user, \user-icon, user.icon-image .then!
			user.icon-image = path
			user.save ->
				res.api-render 'success'
