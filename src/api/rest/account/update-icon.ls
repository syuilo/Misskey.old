require! {
	fs
	gm
	'../../../utils/get-express-params'
	'../../../models/user-icon': UserIcon
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[trim-x, trim-y, trim-w, trim-h] = get-express-params req, <[ trim-x trim-y trim-w trim-h ]>
	UserIcon.find-by-id user.id, (, icon) ->
		if (Object.keys req.files).length == 1
			path = req.files.image.path
			img = gm path
			#if not all empty, [trim-x, trim-y, trim-w, trim-h]
			#	img .= crop trim-w, trim-h, trim-x, trim-y
			#img .= compress \jpeg
			#img .= quality 80
			img.to-buffer \jpeg (err, buffer) ->
				fs.unlink path
				if err?
					console.log err
					res.api-error 500 'error'
				else
					icon
						..image = buffer
						..save (err) ->
							if err?
								console.log err
								res.api-error 500 'error'
							else
								res.api-render 'success'
