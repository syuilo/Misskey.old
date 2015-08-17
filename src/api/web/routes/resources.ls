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

	function read-file-send-less(req, res, path, style-user)
		fs.read-file path, \utf8, (, less-css) ->
			compile-less less-css, style-user, (css) ->
				res
					..header 'Content-type' 'text/css'
					..send css

	# General
	app.get /^\/resources\/.*/ (req, res, next) ->
		is-login = req.session? && req.session.user-id?
		
		switch
		| (req.path.index-of '..') > -1 =>
			res
				..status 400
				..send 'invalid path'
		| _ =>
			switch
			| req.path == /\.css$/ =>
				css-path = path.resolve "#__dirname/..#{req.path}"
				less-path = path.resolve "#__dirname/..#{req.path.replace /\.css$/ '.less'}"
				if fs.exists-sync less-path
					app.init-session req, res, ->
						if is-login
							(, user) <- User.find-by-id req.session.user-id
							read-file-send-less do
								req
								res
								less-path
								user
						else
							read-file-send-less do
								req
								res
								less-path
								null
						
				else if fs.exists-sync css-path
					res.send-file css-path
			| req.url.index-of '.less' == -1 =>
				resource-path = path.resolve "#__dirname/..#{req.path}"
				res.send-file resource-path
			| _ => next!
