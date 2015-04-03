require! {
	fs
	gm
	'../../../models/user-header': UserHeader
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	(, header) <- UserHeader.find-by-id user.id
	if (Object.keys req.files).length == 1
		path = req.files.image.path
		(, image) <- gm path
			.compress \jpeg
			.quality 80
			.to-buffer \jpeg
		(, blurred-image) <- gm path
			.blur 64, 20
			.compress \jpeg
			.quality 80
			.to-buffer \jpeg
		fs.unlink path
		header
			..image = image
			..blur = blurred-image
			..save -> res.api-render 'success'
	else
		res.api-error 400 'Not attached image'
