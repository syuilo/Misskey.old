require! {
	fs
	gm
	'../../../utils/register-image'
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
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
		register-image user, \user-wallpaper "#{user.id}.jpg", \jpg, image .then (path) ->
			register-image user, \user-wallpaper "#{user.id}-blurred.jpg", \jpg, blurred-image .then ->
				user.wallpaper-image = path
				user.save ->
					res.api-render 'success'
	else
		res.api-error 400 'Not attached image'
