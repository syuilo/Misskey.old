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
	if (Object.keys req.files).length == 1
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

	function update(image, img-type)
		filename = "#{user.id}.#{img-type}"
		register-image user, \user-icon, filename, img-type, image .then ->
			delete-image user, \user-icon, user.icon-image .then!
			user.icon-image = filename
			user.save ->
				res.api-render 'success'