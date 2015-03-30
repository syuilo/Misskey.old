require! {
	fs
	gm
	'../../../models/user-wallpaper': UserWallpaper
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	UserWallpaper.find-by-id user.id, (, wallpaper) ->
		if (Object.keys req.files).length == 1
			path = req.files.image.path
			gm path
				.compress \jpeg
				.quality 80
				.to-buffer \jpeg (, buffer) -> 
					fs.unlink path
					wallpaper
						..image = buffer
						..save (err) -> res.api-render 'success'
