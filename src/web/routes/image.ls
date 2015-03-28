#
# Unstatic images router
#

require! {
	fs
	path
	express
	gm
	'../../models/user': User
	'../../models/user-icon': UserIcon
	'../../models/user-header': UserHeader
	'../../models/user-wallpaper': UserWallpaper
	'../../models/status': Status
	'../../models/status-image': StatusImage
	'../../models/talk-message': TalkMessage
	'../../models/talk-message-image': TalkMessageImage
	'../../models/webtheme': Webtheme
	'../../config'
}

module.exports = (app) ->
	# Direct access (display image viewer page)
	function display-image(req, res, image-buffer, image-url, author)
		img = gm image-buffer
		img.size (err, val) ->
			res.display req, res, 'image' {
				image-url
				file-name: author.screen-name + '.jpg'
				author
				width: val.width
				height: val.height
			}
	
	function send-image(req, res, image-buffer)
		switch
		| req.query.blur? =>
			try
				options = parse-json req.query.blur.replace /([a-zA-Z]+)\s?:\s?([^,}"]+)/g '"$1":$2'
				gm image-buffer
					..blur options.radius, options.sigma
					..compress \jpeg
					..quality 80
					..to-buffer \jpeg (, buffer) ->
						res
							..set 'Content-Type' 'image/jpeg'
							..send buffer
			catch e
				res
					..status 400
					..send e
		| _ =>
			res
				..set 'Content-Type' 'image/jpeg'
				..send image-buffer

	function display-user-image(req, res, id-or-sn, image-property-name)
		function display(user, user-image)
			image-buffer = if user-image.image?
				then user-image.image
				else fs.read-file-sync path.resolve "#__dirname/../resources/images/defaults/user/#{image-property-name}.jpg"
			if (req.headers[\accept].index-of \text) == 0
				display-image do
					req
					res
					image-buffer
					"https://misskey.xyz/img/#image-property-name/#id-or-sn"
					user
			else
				send-image req, res, image-buffer
		
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
		
		switch
		| id-or-sn.match /^[0-9]+$/ => User.find-by-id id-or-sn, (, user) -> routing-image user
		| _ => User.find-one { screen-name: id-or-sn } (, user) -> routing-image user
				
	function display-status-image(req, res, id)
		StatusImage.find-one { status-id: id } (, status-image) ->
			| status-image? =>
				image-buffer = status-image.image
				Status.find-by-id status-image.status-id, (, status) ->
					if (req.headers[\accept].index-of \text) == 0
						User.find-by-id status.user-id, (, user) ->
							display-image do
								req
								res
								image-buffer
								"https://misskey.xyz/img/post/#id"
								user
					else
						send-image req, res, image-buffer
			| _ =>
				res
					..status 404
					..send 'Image not found.'

	function display-talkmessage-image(req, res, id)
		TalkMessageImage.find-one { message-id: id } (, talkmessage-image) ->
			| talkmessage-image? =>
				TalkMessage.find-by-id talkmessage-image.message-id, (, talkmessage) ->
					err = switch
						| !req.login => [403 'Access denied.']
						| req.me.id != talkmessage.user-id && req.me.id != talkmessage.otherparty-id => [403 'Access denied.']
						| _ => null
					if err == null
						image-buffer = talkmessage-image.image;
						if (req.headers[\accept].index-of \text) == 0
							User.find-by-id talkmessage.user-id, (, user) ->
								display-image do
									req
									res
									image-buffer
									"https://misskey.xyz/img/talk-message/#id"
									user
						else
							send-image req, res, image-buffer
					else
						res
							..status err.0
							..send err.1
			| _ =>
				res
					..status 404
					..send 'Image not found.'
	
	# User icon
	app.get '/img/icon/:idorsn' (req, res) ->
		id-or-sn = req.params.idorsn
		display-user-image req, res, id-or-sn, \icon

	# User header
	app.get '/img/header/:idorsn' (req, res) ->
		id-or-sn = req.params.idorsn
		display-user-image req, res, id-or-sn, \header

	# User wallpaper
	app.get '/img/wallpaper/:idorsn' (req, res) ->
		id-or-sn = req.params.idorsn
		display-user-image req, res, id-or-sn, \wallpaper

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
