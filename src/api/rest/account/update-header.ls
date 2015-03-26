require! {
	fs
	gm
	'../../../models/user-header': UserHeader
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	UserHeader.find-one { user-id: user.id } (, header) ->
		if (Object.keys req.files).length == 1
			path = req.files.image.path
			gm path
				.compress \jpeg
				.quality 80
				.to-buffer \jpeg (, buffer) ->
					fs.unlink path
					header
						..image = buffer
						..save (err) -> res.api-render 'success'
