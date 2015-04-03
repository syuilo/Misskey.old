#
# Resources router
#

require! {
	fs
	path
	express
	gm
	compression
	less
	'../../config'
	'../../utils/get-express-params'
	'../../models/user': User
	'../../models/webtheme': Webtheme
}

module.exports = (app) ->
	function compile-less (less-css, style-user, callback)
		color = if style-user? && style-user.color == /#[a-fA-F0-9]{6}/
			then style-user.color
			else config.theme-color
		less.render do
			pre-compile less-css, style-user, color
			{ +compress }
			(err, output) ->
				if err then throw err
				callback output.css
		
		# Analyze variable
		function pre-compile(less-css, style-user, color)
			less-css
				.replace do
					/<%themeColor%>/g
					color
				.replace do
					/<%wallpaperUrl%>/g
					if style-user?
						then "\"#{config.public-config.url}/img/wallpaper/#{style-user.screen-name}\""
						else ''
				.replace do
					/<%blurredWallpaperUrl%>/g
					if style-user?
						then "\"#{config.public-config.url}/img/wallpaper/#{style-user.screen-name}/blur\""
						else ''
				.replace do
					/<%headerImageUrl%>/g
					if style-user?
						then "\"#{config.public-config.url}/img/header/#{style-user.screen-name}\""
						else ''
				.replace do
					/<%blurredHeaderImageUrl%>/g
					if style-user?
						then "\"#{config.public-config.url}/img/header/#{style-user.screen-name}/blur\""
						else ''
	
	function read-file-send-less(req, res, path, style-user)
		fs.read-file path, \utf8, (, less-css) ->
			compile-less less-css, style-user, (css) ->
				res
					..header 'Content-type' 'text/css'
					..send css
	
	# Theme
	app.get /^\/resources\/styles\/theme\/([a-zA-Z0-9_-]+).*/ (req, res, next) ->
		[user] = get-express-params req, <[ user ]>
		| !empty user =>
			User.find-one { screen-name: req.query.user } (, theme-user) ->
				| theme-user? =>
					send-theme-style(theme-user);
				| _ =>
					res
						..status(404)
						..send 'User not found.'
		| _ =>
			app.init-session req, res, ->
				| req.login => send-theme-style req.me
				| _ => res.send
		
		function send-theme-style(user)
			[style-name] = get-express-params req, <[ 0 ]>
			theme-id = user.web-theme-id
			switch
			| theme-id == null => res.send!
			| _ => Webtheme.find-by-id theme-id, (, theme) ->
				| theme == null => res.send!
				| _ =>
					try
						theme-obj = parse-json theme.style
						if theme-obj[style-name]
							compile-less theme-obj[style-name], user, (css) ->
								res
									..header 'Content-type' 'text/css'
									..send css
						else
							res.send!
					catch e
						res
							..status 500
							..send 'Theme parse failed.'
		
		[user] = get-express-params req, <[ user ]>
		if !empty user
			User.find-one {screem-name: user} (, theme-user) ->
				if theme-user?
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
					res.send!
	
	# General
	app.get /^\/resources\/.*/ (req, res, next) ->
		| (req.path.index-of '..') > -1 =>
			res
				..status 400
				..send 'invalid path'
		| _ =>
			switch
			| req.path == /\.css$/ =>
				resource-path = path.resolve "#__dirname/..#{req.path.replace /\.css$/ '.less'}"
				if fs.exists-sync resource-path
					app.init-session req, res, ->
						[user] = get-express-params req, <[ user ]>
						switch
						| !empty user
							User.find-one {screen-name: user} (, style-user) ->
								read-file-send-less do
									req
									res
									resource-path
									if style-user? then style-user else null
						| _ =>
							read-file-send-less do
								req
								res
								resource-path
								if req.login then req.me else null
			| req.url.index-of '.less' == -1 =>
				resource-path = path.resolve "#__dirname/..#{req.path}"
				res.send-file resource-path
			| _ => next!
