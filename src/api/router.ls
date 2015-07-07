routing =
	web:
		[\post /\/web\/status\/reply(\..+)?$/   './rest/web/status/reply']
		[\get  /\/web\/status\/timeline-homehtml(\..+)?$/   './rest/web/status/timeline-homehtml']
		
	account:
		[\post   /\/account\/create(\..+)?$/               './rest/account/create']
		[\get    /\/account\/show(\..+)?$/                 './rest/account/show']
		[\put    /\/account\/update(\..+)?$/               './rest/account/update']
		[\put    /\/account\/update-icon(\..+)?$/          './rest/account/update-icon']
		[\put    /\/account\/update-header(\..+)?$/        './rest/account/update-header']
		[\put    /\/account\/update-wallpaper(\..+)?$/     './rest/account/update-wallpaper']
		[\delete /\/account\/delete-wallpaper(\..+)?$/     './rest/account/delete-wallpaper']
		[\put    /\/account\/update-webtheme(\..+)?$/      './rest/account/update-webtheme']
		[\get    /\/account\/unreadalltalks-count(\..+)?$/ './rest/account/unreadalltalks-count']
		[\delete /\/account\/reset-webtheme(\..+)?$/       './rest/account/reset-webtheme']

	application:
		[\post /\/application\/create(\..+)?$/ './rest/application/create']
		[\post /\/application\/delete(\..+)?$/ './rest/application/delete']

	search:
		[\get /\/search\/user(\..+)?$/ './rest/search/user']
		[\get /\/search\/kyoppie(\..+)?$/ './rest/search/user'] #dummy

	notice:
		[\delete /\/notice\/delete(\..+)?$/     './rest/notice/delete']
		[\delete /\/notice\/delete-all(\..+)?$/ './rest/notice/delete-all']
		[\get    /\/notice\/timeline-webhtml(\..+)?$/ './rest/notice/timeline-webhtml']

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

	bbs:
		[\post   /\/bbs\/thread\/create(\..+)?$/     './rest/bbs/thread/create']
		[\put    /\/bbs\/thread\/update(\..+)?$/     './rest/bbs/thread/creupdateate']
		[\post   /\/bbs\/thread\/favorite(\..+)?$/   './rest/bbs/thread/favorite']
		[\post   /\/bbs\/thread\/watch(\..+)?$/      './rest/bbs/thread/watch']
		[\delete /\/bbs\/thread\/unfavorite(\..+)?$/ './rest/bbs/thread/unfavorite']
		[\delete /\/bbs\/thread\/unwatch(\..+)?$/    './rest/bbs/thread/unwatch']
		[\post   /\/bbs\/post\/create(\..+)?$/       './rest/bbs/post/create']

	circle:
		[\post /\/circle\/create(\..+)?$/ './rest/circle/create']
		[\get  /\/circle\/show(\..+)?$/   './rest/circle/show']
		[\put  /\/circle\/update(\..+)?$/ './rest/circle/update']

	other:
		[\get /\/screenname-available(\..+)?$/ './rest/screenname-available']
		[\all /\/teapot\/coffee(\..+)?$/       './rest/teapot/coffee']


module.exports = (app) ->
	app
		..all '*' (req, res, next) ->
			filename = req.url.match /.+\/(.+?)([\?#;].*)?$/
			if filename?
				extension = filename.1.match /\.(.+)$/
				req.format = extension.1 if extension?
			next!

	routing |> values |> concat |> each ([method, url, handler]) ->
		app[method] url, require handler
