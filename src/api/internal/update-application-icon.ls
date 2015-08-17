require! {
	fs
	gm
	'image-type': image-type
	'../../models/status': Status
	'../../models/application': Application
	'../../utils/register-image'
}

module.exports = (app, user, app-id, image, trim-x = null, trim-y = null, trim-w = null, trim-h = null) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	(err, target-app) <- Application.find-by-id app-id
	switch
	| !target-app? => throw-error \app-not-found 'Application not found.'
	| target-app.user-id.to-string! != user.id.to-string! => throw-error \app-access-denied 'Application access denied.'
	| _ =>
		if image?
			# Detect the image type
			img-type = (image-type image).ext
			switch (img-type)
			| \gif =>
				if user.is-plus
					update image, \gif
				else
					throw-error \denied-gif-upload 'Denied GIF upload (plus-account only).'
			| _ => 
				img = gm image
				if not all null-or-empty, [trim-x, trim-y, trim-w, trim-h]
					img .= crop trim-w, trim-h, trim-x, trim-y
				img .= compress \jpeg
				img .= quality 90
				img.to-buffer \jpeg (err, buffer) ->
					if err? || !buffer?
						throw-error \failed-attach-image 'Failed attach image.'
					else
						create buffer, \jpg

	function update(image, img-type)
		image-name = "#{target-app.id}.#{img-type}"
		register-image user, \app-icon image-name, img-type, image .then (path) ->
			target-app.icon-image = path
			target-app.save ->
				resolve target-app
