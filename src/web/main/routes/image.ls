#
# Unstatic images router
#

require! {
	fs
	path
	express
	gm
	'../../../models/user': User
	'../../../models/user-icon': UserIcon
	'../../../models/user-header': UserHeader
	'../../../models/user-wallpaper': UserWallpaper
	'../../../models/status': Status
	'../../../models/status-image': StatusImage
	'../../../models/talk-message': TalkMessage
	'../../../models/talk-message-image': TalkMessageImage
	'../../../models/webtheme': Webtheme
	'../../../config'
}

module.exports = (app) ->
	function send-error-image(res, message)
		buffer = fs.read-file-sync path.resolve "#__dirname/../resources/images/image-error-bg.png"
		(, image) <- gm buffer
			.draw-text 0 32 message
			.compress \jpeg
			.quality 80
			.to-buffer \jpeg
		res
			..set \Content-Type \image/jpeg
			..send image
	
	# Direct access (display image viewer page)
	function display-image(req, res, image-buffer, image-url, author, image-id)
		if image-buffer?
			img = gm image-buffer
			img.size (err, val) ->
				if err then console.log err
				width = val.width
				height = val.height
				res.display req, res, 'image' {
					image-url
					file-name: "#{author.screen-name}.jpg"
					author
					width
					height
				}
		else
			send-error-image res, "エラー: バッファがNullです。\nIMGID: #image-id"

	function send-image(req, res, image-buffer, image-id)
		if image-buffer?
			res
				..set \Content-Type \image/jpeg
				..send image-buffer
		else
			send-error-image res, "エラー: バッファがNullです。\nIMGID: #image-id"

	function display-user-image(req, res, sn, image-property-name, image-type = \image)
		function display(user, user-image)
			image-buffer = if user-image[image-type]?
				then user-image[image-type]
				else fs.read-file-sync path.resolve "#__dirname/../resources/images/defaults/user/#{image-property-name}[#{image-type}].jpg"
			send-image req, res, image-buffer, "#{user-image.id} #{image-type}"

		function routing-image(user)
			switch
			| user? =>
				switch image-property-name
				| \icon =>
					UserIcon.find-by-id user.id, (, user-image) ->
						display user, user-image
				| \header =>
					UserHeader.find-by-id user.id, (, user-image) ->
						display user, user-image
				| \wallpaper =>
					UserWallpaper.find-by-id user.id, (, user-image) ->
						display user, user-image
				| _ =>
					res
						..status 500
						..send "Invalid type: #image-property-name"
			| _ =>
				res
					..status 404
					..send 'User not found.'

		User.find-one {screen-name: sn} (, user) -> routing-image user

	function display-status-image(req, res, id)
		StatusImage.find-one {status-id: id} (, status-image) ->
			| status-image? =>
				image-buffer = status-image.image
				Status.find-by-id status-image.status-id, (, status) ->
					send-image req, res, image-buffer, status-image.id
			| _ =>
				res
					..status 404
					..send 'Image not found.'

	function display-talkmessage-image(req, res, id)
		TalkMessageImage.find-one {message-id: id} (, talkmessage-image) ->
			| talkmessage-image? =>
				TalkMessage.find-by-id talkmessage-image.message-id, (, talkmessage) ->
					err = switch
						| !req.login => [403 'Access denied.']
						| req.me.id.to-string! != talkmessage.user-id.to-string! && req.me.id.to-string! != talkmessage.otherparty-id.to-string! => [403 'Access denied.']
						| _ => null
					if !err?
						image-buffer = talkmessage-image.image
						send-image req, res, image-buffer, talkmessage-image.id
					else
						res
							..status err.0
							..send err.1
			| _ =>
				res
					..status 404
					..send 'Image not found.'

	# User icon
	app.get '/img/icon/:sn' (req, res) ->
		display-user-image req, res, req.params.sn, \icon

	# User header
	app.get '/img/header/:sn' (req, res) ->
		display-user-image req, res, req.params.sn, \header

	# User header (Blur)
	app.get '/img/header/:sn/blur' (req, res) ->
		display-user-image req, res, req.params.sn, \header \blur

	# User wallpaper
	app.get '/img/wallpaper/:sn' (req, res) ->
		display-user-image req, res, req.params.sn, \wallpaper

	# User wallpaper (Blur)
	app.get '/img/wallpaper/:sn/blur' (req, res) ->
		display-user-image req, res, req.params.sn, \wallpaper \blur

	# Status
	app.get '/img/status/:id' (req, res) ->
		id = req.params.id
		display-status-image req, res, id

	# Talk message
	app.get '/img/talk-message/:id' (req, res) ->
		id = req.params.id
		display-talkmessage-image req, res, id

	# Webtheme thumbnail
	app.get '/img/webtheme-thumbnail/:id' (req, res) ->
		id = req.params.id
		Webtheme.find-by-id id, (, webtheme) ->
			| webtheme? =>
				image-buffer = webtheme.thumbnail
				send-image req, res, image-buffer
			| _ =>
				res
					..status 404
					..send 'WebTheme not found.'
