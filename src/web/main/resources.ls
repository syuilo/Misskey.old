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
	'../../models/user': User
	'../../models/webtheme': Webtheme
	'../../config'
}

function send-empty-style(res)
	res
		..header \Content-type \text/css
		..send '*{}'

module.exports = (app) ->
	function compile-less (less-css, style-user, callback)
		color = if style-user? && style-user.color == /#[a-fA-F0-9]{6}/
			then style-user.color
			else config.public-config.theme-color
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
						then "\"#{style-user.wallpaper-image-url}\""
						else ''
				.replace do
					/<%blurredWallpaperUrl%>/g
					if style-user?
						then "\"#{style-user.blurred-wallpaper-image-url}\""
						else ''
				.replace do
					/<%headerImageUrl%>/g
					if style-user?
						then "\"#{style-user.banner-image-url}\""
						else ''
				.replace do
					/<%blurredHeaderImageUrl%>/g
					if style-user?
						then "\"#{style-user.blurred-banner-image-url}\""
						else ''
				.replace do
					/<%mobileHeaderImageUrl%>/g
					if style-user?
						then "\"#{config.public-config.url}/resources/images/mobile-header-designs/#{style-user.mobile-header-design-id}.svg\""
						else ''

	function read-file-send-less(req, res, path, style-user)
		fs.read-file path, \utf8, (, less-css) ->
			compile-less less-css, style-user, (css) ->
				res
					..header 'Content-type' 'text/css'
					..send css

	# General
	app.get /^\/resources\/.*/ (req, res, next) ->
		| (req.path.index-of '..') > -1 =>
			res
				..status 400
				..send 'invalid path'
		| _ =>
			switch
			| req.path == /\.css$/ =>
				if req.is-mobile
					css-path = path.resolve "#__dirname/sites/mobile/#{req.path}"
					less-path = path.resolve "#__dirname/sites/mobile/#{req.path.replace /\.css$/ '.less'}"
				else
					css-path = path.resolve "#__dirname/sites/desktop/#{req.path}"
					less-path = path.resolve "#__dirname/sites/desktop/#{req.path.replace /\.css$/ '.less'}"

				if fs.exists-sync less-path
					if req.query.user?
						User.find-one {screen-name: req.query.user} (, style-user) ->
							read-file-send-less do
								req
								res
								less-path
								if style-user? then style-user else null
					else
						read-file-send-less do
							req
							res
							less-path
							if req.login then req.me else null
				else if fs.exists-sync css-path
					res.send-file css-path

			| req.url.index-of '.less' == -1 =>
				resource-path = path.resolve "#__dirname/#{req.path}"
				res.send-file resource-path
			| _ => next!
