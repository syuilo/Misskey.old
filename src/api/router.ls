require! {
	'./github-webhook': github-webhook
	'./web/routes/resources': web-resources-router
	'./web/routes/index': web-index-router
	'../config'
}

routing =
	web:
		[\post /\/web\/status\/reply(\..+)?$/             './rest/web/status/reply']
		[\post /\/web\/status\/reply-detail(\..+)?$/             './rest/web/status/reply-detail']
		[\post /\/web\/status\/reply-detail-one(\..+)?$/             './rest/web/status/reply-detail-one']
		[\get  /\/web\/status\/get-talk-detail-html(\..+)?$/             './rest/web/status/get-talk-detail-html']
		[\get  /\/web\/status\/get-talk-detail-one-html(\..+)?$/             './rest/web/status/get-talk-detail-one-html']
		[\get  /\/web\/status\/timeline-homehtml(\..+)?$/ './rest/web/status/timeline-homehtml']
		[\get  /\/web\/status\/user-timeline-detailhtml(\..+)?$/ './rest/web/status/user-timeline-detailhtml']
		[\get  /\/web\/status\/user-timeline-detail-one-html(\..+)?$/ './rest/web/status/user-timeline-detail-one-html']
		[\get  /\/web\/status\/timeline-mobilehomehtml(\..+)?$/ './rest/web/status/timeline-mobilehomehtml']
		[\get  /\/web\/talk\/timeline-html(\..+)?$/       './rest/web/talk/timeline-html']
		[\get  /\/web\/get-header-statuses(\..+)?$/       './rest/web/get-header-statuses']

	sauth:
		[\get    /\/sauth\/get-authentication-session-key(\..+)?$/ './rest/sauth/get-authentication-session-key']
		[\get    /\/sauth\/get-user-key(\..+)?$/                   './rest/sauth/get-user-key']

	account:
		[\post   /\/account\/create(\..+)?$/                      './rest/account/create']
		[\get    /\/account\/show(\..+)?$/                        './rest/account/show']
		[\put    /\/account\/update-pinned-status(\..+)?$/        './rest/account/update-pinned-status']
		[\delete /\/account\/delete-pinned-status(\..+)?$/        './rest/account/delete-pinned-status']
		[\delete /\/account\/remove-app(\..+)?$/                  './rest/account/remove-app']
		[\put    /\/account\/update(\..+)?$/                      './rest/account/update']
		[\put    /\/account\/update-name(\..+)?$/                 './rest/account/update-name']
		[\put    /\/account\/update-comment(\..+)?$/              './rest/account/update-comment']
		[\put    /\/account\/update-bio(\..+)?$/                  './rest/account/update-bio']
		[\put    /\/account\/update-location(\..+)?$/             './rest/account/update-location']
		[\put    /\/account\/update-url(\..+)?$/                  './rest/account/update-url']
		[\put    /\/account\/update-color(\..+)?$/                './rest/account/update-color']
		[\put    /\/account\/update-icon(\..+)?$/                 './rest/account/update-icon']
		[\put    /\/account\/update-banner(\..+)?$/               './rest/account/update-banner']
		[\put    /\/account\/update-wallpaper(\..+)?$/            './rest/account/update-wallpaper']
		[\put    /\/account\/update-home-layout(\..+)?$/          './rest/account/update-home-layout']
		[\put    /\/account\/update-room(\..+)?$/                 './rest/account/update-room']
		[\delete /\/account\/delete-wallpaper(\..+)?$/            './rest/account/delete-wallpaper']
		[\put    /\/account\/update-mobile-header-design(\..+)?$/ './rest/account/update-mobile-header-design']
		[\put    /\/account\/update-webtheme(\..+)?$/             './rest/account/update-webtheme']
		[\get    /\/account\/unreadalltalks-count(\..+)?$/        './rest/account/unreadalltalks-count']
		[\delete /\/account\/reset-webtheme(\..+)?$/              './rest/account/reset-webtheme']

	application:
		[\post /\/application\/create(\..+)?$/      './rest/application/create']
		[\put  /\/application\/update-icon(\..+)?$/ './rest/application/update-icon']
		[\post /\/application\/delete(\..+)?$/      './rest/application/delete']

	search:
		[\get /\/search\/user(\..+)?$/ './rest/search/user']
		[\get /\/search\/kyoppie(\..+)?$/ './rest/search/user'] #dummy

	notice:
		[\post   /\/notice\/create(\..+)?$/           './rest/notice/create']
		[\get    /\/notice\/show(\..+)?$/             './rest/notice/show']
		[\get    /\/notice\/timeline(\..+)?$/         './rest/notice/timeline']
		[\delete /\/notice\/delete(\..+)?$/           './rest/notice/delete']
		[\delete /\/notice\/delete-all(\..+)?$/       './rest/notice/delete-all']
		[\get    /\/notice\/timeline-webhtml(\..+)?$/ './rest/notice/timeline-webhtml']

	users:
		[\get    /\/users\/show(\..+)?$/     './rest/users/show']
		[\post   /\/users\/follow(\..+)?$/   './rest/users/follow']
		[\delete /\/users\/unfollow(\..+)?$/ './rest/users/unfollow']

	status:
		[\get  /\/status\/show(\..+)?$/     './rest/status/show']
		[\post /\/status\/update(\..+)?$/   './rest/status/update']
		[\post /\/status\/favorite(\..+)?$/ './rest/status/favorite']
		[\post /\/status\/repost(\..+)?$/   './rest/status/repost']
		[\get  /\/status\/timeline(\..+)?$/ './rest/status/timeline']
		[\get  /\/status\/mentions(\..+)?$/ './rest/status/mentions']

	talk:
		[\post   /\/talk\/say(\..+)?$/    './rest/talk/say']
		[\put    /\/talk\/fix(\..+)?$/    './rest/talk/fix']
		[\delete /\/talk\/delete(\..+)?$/ './rest/talk/delete']
		[\post   /\/talk\/read(\..+)?$/   './rest/talk/read']

	bbs:
		[\post   /\/bbs\/thread\/create(\..+)?$/     './rest/bbs/thread/create']
		[\put    /\/bbs\/thread\/update(\..+)?$/     './rest/bbs/thread/update']
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

	github-webhook app

	web-resources-router app
	web-index-router app
