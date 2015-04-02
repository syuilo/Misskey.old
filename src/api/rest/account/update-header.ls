require! {
	fs
	gm
	'../../../models/user-header': UserHeader
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	(, header) <- UserHeader.find-by-id user.id
	if req.files.length == 1
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
			..blurred-image = blurred-image
			..save -> res.api-render 'success'
