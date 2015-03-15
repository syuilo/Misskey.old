require! {
	fs
	path
	express
	gm
	'../../models/user': User
	'../../models/user-image': UserImage
	'../../models/post-image': StatusImage
	'../../models/talk-message': TalkMessage
	'../../models/talk-message-image': TalkMessageImage
	'../../models/webtheme': Webtheme
	'../../config': config
}

module.exports = (app) ->
	function display-image(req, res, image-buffer, img-url, file-name, author)
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
		if req.query.blur != null
			try
				options = JSON.parse req.query.blur.replace /([a-zA-Z]+)\s?:\s?([^,}"]+)/g '"$1":$2'
				gm image-buffer
					..blur options.radius, options.sigma
					..compress 'jpeg'
					..quality 80
					..to-buffer 'jpeg' (err, buffer) ->
						if error then throw error
						res
							..set 'Content-Type' 'image/jpeg'
							..send buffer
			catch e
				res
					..status 400
					..send e
		else
			res
				..set 'Content-Type' 'image/jpeg'
				..send image-buffer
	
	# User icon
	app.get '/img/icon/:idOrSn' (req, res) ->
		idOrSn = req.params.idOrSn
		display(user, user-image) ->
			if user-image != null
				image-buffer = user-image.icon != null ? user-image.icon : fs.read-file-sync path.resolve __dirname + '/../resources/images/icon_default.jpg'
				if req.headers['accept'].index-of 'text' == 0
					display-image req, res, image-buffer, 'https://misskey.xyz/img/icon/' + idOrSn, user.screen-name
				else
					send-image req, res, image-buffer
		if idOrSn.match /^[0-9]+$/
			User.find idOrSn, (user) ->
				if user == null
					res
						.status 404
						.send 'User not found.'
					return
				UserImage.find Number idOrSn, (user-image) ->
					display user, user-image
		else
			User.findByScreenName idOrSn, (user) ->
				if user == null
					res
						.status 404
						.send 'User not found.'
					return
				UserImage.find user.id, (user-image) ->
					display user, user-image