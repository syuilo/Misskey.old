require! {
	fs
	gm
	'../../../models/user-icon': UserIcon
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	UserIcon.find-by-id user.id, (, icon) ->
		if (Object.keys req.files).length == 1
			path = req.files.image.path
			gm path
				.compress \jpeg
				.quality 80
				.to-buffer \jpeg (, buffer) ->
					fs.unlink path
					icon
						..image = buffer
						..save (err) -> res.api-render 'success'
