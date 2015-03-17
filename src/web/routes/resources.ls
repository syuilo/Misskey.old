require! {
	fs
	path
	express
	gm
	compression
	less
	'../../models/user': User
	'../../models/webtheme': Webtheme
	'../../config': config
}

module.exports = (app) ->
	function compile-less (less-css, style-user, callback)
		color = if style-user != null && style-user.color.match(/#[a-fA-F0-9]{6}/)
			then style-user.color
			else config.theme-color
		less.render do
			pre-compile less-css, style-user, color
			{ compress: true }
			(err, output) ->
				if err then throw err
				callback output.css
		
		function pre-compile(less-css, style-user, color)
			less-css
				.replace do
					/<%themeColor%>/g
					color
				.replace do
					/<%wallpaperUrl%>/g
					if styleUser != null
						then "\"#{config.public-config.url}/img/wallpaper/#{style-user.screen-name}\""
						else ''
				.replace do
					/<%headerImageUrl%>/g
					if styleUser != null
						then "\"#{config.public-config.url}/img/header/#{style-user.screen-name}\""
						else ''
				.replace do
					/<%headerBlurImageUrl%>/g
					if styleUser != null
						then "\"#{config.public-config.url}/img/header/#{style-user.screen-name}?blur={radius: 64, sigma: 20}\""
						else ''
	
	function read-file-send-less(req, res, path, style-user)
		fs.read-file path, 'utf8', (err, less-css) ->
			if err then throw err
			compile-less less-css, style-user, (css) ->
				res
					..header 'Content-type' 'text/css'
					..send css
	
	# Theme
	app.get /^\/resources\/styles\/theme\/([a-zA-Z0-9_-]+).*/ (req, res, next) ->
		function send-theme-style(user) ->
			style-name = req.params[0]
			theme-id = user.web-theme-id
			if theme-id == null
				res.send ''
				return
			Webtheme.find theme-id, (theme) ->
				if theme == null
					res.send ''
					return
				try
					theme-obj = JSON.parse theme.style
					if theme-obj[styleName]
						compile-less theme-obj[styleName], user, (css) ->
							res
								..header 'Content-type' 'text/css'
								..send css
					else
						res.send('');
				catch e
					res
						..status 500
						..send 'Theme parse failed.'
		
		if req.query.user != void 0 && req.query.user != null
			User.find-by-screen-name req.query.user, (theme-user) ->
				if theme-user != null
					send-theme-style theme-user
				else
					res
						..status 404
						..send 'User not found.'
		else
			app.init-session req, res, ->
				if req.login
					send-theme-style req.me
				else
					res.send ''
	
	# General
	app.get /^\/resources\/.*/ (req, res, next) ->
		if req.path.index-of '..' > -1
			res
				..status 400
				..send 'invalid path'
			return;
		if req.path.match /\.css$/
			resource-path = path.resolve __dirname + '/..' + req.path.replace /\.css$/ '.less'
			if fs.exists-sync resource-path
				app.init-session req, res, ->
					if req.query.user == void 0 || req.query.user == null
						read-file-send-less do
							req
							res
							resource-path
							if req.login then req.me else null
					else
						User.find-by-screen-name req.query.user, (style-user) ->
							read-file-send-less do
								req
								res
								resource-path
								if styleUser != null then styleUser else null
				return
		if req.url.index-of '.less' == -1
			resource-path = path.resolve __dirname + '/..' + req.path
			res.send-file resource-path
		else
			next!