require! {
	fs
	gm
	'../../../models/user-image': UserImage
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
		UserImage.find user.id, (user-image) ->
			if (Object.keys req.files).length == 1
				path = req.files.image.path
				gmpath
					.compress 'jpeg'
					.quality 80
					.to-buffer 'jpeg' (error, buffer) -> 
						throw error if error
						fs.unlink path
						user-image
							..wallpaper = buffer
							..update -> res.api-render user.filt!
