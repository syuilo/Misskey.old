require! {
	'../../../models/user-wallpaper': UserWallpaper
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	UserWallpaper.find-by-id user.id, (, wallpaper) ->
		wallpaper
			..image = null
			..save -> res.api-render 'success'
