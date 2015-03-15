require! {
	fs
	gm
	'../../../models/user-image': UserImage
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	UserImage.find user.id, (user-image) ->
		if (Object.keys req.files).length == 1
			path = req.files.image.path
			gm path
				.compress 'jpeg'
				.quality 80
				.to-buffer 'jpeg' (error, buffer) ->
					throw error if error
					fs.unlink path
					user-image
						..icon = buffer
						..update -> res.api-render user.filt!
