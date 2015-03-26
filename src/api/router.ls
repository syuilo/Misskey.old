routing =
	account:
		[\post   /\/account\/create(\..+)?$/               './rest/account/create']
		[\get    /\/account\/show(\..+)?$/                 './rest/account/show']
		[\put    /\/account\/update(\..+)?$/               './rest/account/update']
		[\put    /\/account\/updateIcon(\..+)?$/          './rest/account/update-icon']
		[\put    /\/account\/updateHeader(\..+)?$/        './rest/account/update-header']
		[\put    /\/account\/updateWallpaper(\..+)?$/     './rest/account/update-wallpaper']
		[\put    /\/account\/updateWebtheme(\..+)?$/      './rest/account/update-webtheme']
		[\get    /\/account\/unreadalltalksCount(\..+)?$/ './rest/account/unreadalltalks-count']
		[\delete /\/account\/resetWebtheme(\..+)?$/       './rest/account/reset-webtheme']
	
	application:
		[\post /\/application\/create(\..+)?$/ './rest/application/create']
		[\post /\/application\/delete(\..+)?$/ './rest/application/delete']
	
	notice:
		[\delete /\/notice\/delete(\..+)?$/    './rest/notice/delete']
		[\delete /\/notice\/deleteall(\..+)?$/ './rest/notice/deleteall']
	
	users:
		[\get    /\/users\/show(\..+)?$/     './rest/users/show']
		[\post   /\/users\/follow(\..+)?$/   './rest/users/follow']
		[\delete /\/users\/unfollow(\..+)?$/ './rest/users/unfollow']
	
	status:
		[\post /\/status\/update(\..+)?$/   './rest/status/update']
		[\post /\/status\/favorite(\..+)?$/ './rest/status/favorite']
		[\post /\/status\/repost(\..+)?$/   './rest/status/repost']
		[\get  /\/status\/timeline(\..+)?$/ './rest/status/timeline']
	
	talk:
		[\post   /\/talk\/say(\..+)?$/    './rest/talk/say']
		[\put    /\/talk\/fix(\..+)?$/    './rest/talk/fix']
		[\delete /\/talk\/delete(\..+)?$/ './rest/talk/delete']
		[\post   /\/talk\/read(\..+)?$/   './rest/talk/read']
	
	circle:
		[\post /\/circle\/create(\..+)?$/ './rest/circle/create']
		[\get  /\/circle\/show(\..+)?$/   './rest/circle/show']
		[\put  /\/circle\/update(\..+)?$/ './rest/circle/update']
	
	other:
		[\get /\/search\/user(\..+)?$/         './rest/search/user']
		[\get /\/screenname_available(\..+)?$/ './rest/screenname-available']
		[\all /\/teapot\/coffee(\..+)?$/       './rest/teapot/coffee']


module.exports = (app) ->
	app
		..all '*' (req, res, next) ->
			filename = req.url.match /.+\/(.+?)([\?#;].*)?$/
			if filename?
				extension = filename.1.match /\.(.+)$/
				req.format = extension.1 if extension != null
			next!
		
		# Authorize
		..get  '/authorize' require './application-authorize/authorize-get'
		..post '/authorize' (req, res) -> (require './application-authorize/authorize-post') req, res, app
		..get  /\/sauth\/get_request_token(\..+)?$/ require './rest/sauth/get_request_token'
	
	routing |> values |> concat |> each ([method, url, handler]) ->
		app[method] url, require handler
