require! {
	fs
	gm
	'../../../utils/get-express-params'
	'../../../models/user-header': UserHeader
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[trim-x, trim-y, trim-w, trim-h] = get-express-params req, <[ trim-x trim-y trim-w trim-h ]>
	(, header) <- UserHeader.find-by-id user.id
	if (Object.keys req.files).length == 1
		path = req.files.image.path
		normal-image = gm path
		if not all empty, [trim-x, trim-y, trim-w, trim-h]
			normal-image .= crop trim-w, trim-h, trim-x, trim-y
		blurred-image = normal-image.blur 64, 20
		normal-image .= compress \jpeg
		normal-image .= quality 80
		(, normal-image-buffer) <- normal-image.to-buffer \jpeg
		blurred-image .= compress \jpeg
		blurred-image .= quality 80
		(, blurred-image-buffer) <- blurred-image.to-buffer \jpeg
		fs.unlink path
		header
			..image = image
			..blur = blurred-image
			..save -> res.api-render 'success'
	else
		res.api-error 400 'Not attached image'
