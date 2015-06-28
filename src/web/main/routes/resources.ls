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
	'../../../models/user': User
	'../../../models/webtheme': Webtheme
	'../../../config'
}

function send-empty-style(res)
	res
		..header \Content-type \text/css
		..send '*{}'

module.exports = (app) ->
	function compile-less (less-css, style-user, callback)
		color = if style-user? && style-user.color == /#[a-fA-F0-9]{6}/
			then style-user.color
			else config.theme-color
		less.render do
			pre-compile less-css, style-user, color
			{+compress}
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
		| req.query.user? =>
			User.find-one {screen-name-lower: req.query.user.to-lower-case!} (, theme-user) ->
				| theme-user? =>
					send-theme-style theme-user
				| _ =>
					res
						..status 404
						..send 'User not found.'
		| _ =>
			app.init-session req, res, ->
				| req.login => send-theme-style req.me
				| _ => send-empty-style res

		function send-theme-style(user)
			style-name = req.params.0
			theme-id = user.web-theme-id
			switch
			| !theme-id? => send-empty-style res
			| _ => Webtheme.find-by-id theme-id, (, theme) ->
				| !theme? => send-empty-style res
				| _ =>
					try
						theme-obj = parse-json theme.style
						if theme-obj[style-name]
							compile-less theme-obj[style-name], user, (css) ->
								res
									..header 'Content-type' 'text/css'
									..send css
						else
							send-empty-style res
					catch e
						res
							..status 500
							..send 'Theme parse failed.'

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
						| req.query.user? =>
							User.find-one {screen-name: req.query.user} (, style-user) ->
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
