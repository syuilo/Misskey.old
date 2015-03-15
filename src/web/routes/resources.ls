require! {
	fs
	path
	express
	gm
	compression
	less
	'../../models/user'
	'../../models/webtheme'
}

'../../config': config

export = router

compile-less (less-css, style-user, callback) ->
	color = (style-user != null && style-user.color.match(/#[a-fA-F0-9]{6}/)) ? style-user.color : config.theme-color)
	less.render