require! {
	express
}
module.exports = (app) ->
	app
		..all '*' (req, res, next) ->
			filename = req.url.match /.+\/(.+?)([\?#;].*)?$/
			if filename?
				extension = filename.1.match /\.(.+)$/
				req.format = extension.1 if extension != null
			next!
		..get '/authorize' require './authorize-get'
		..post '/authorize' (req, res) -> (require './authorize-post') req, res, app
		..get    /\/sauth\/get_request_token(\..+)?$/      require './rest/sauth/get_request_token'
		..post   /\/account\/create(\..+)?$/               require './rest/account/create'
		..get    /\/account\/show(\..+)?$/                 require './rest/account/show'
		..put    /\/account\/update(\..+)?$/               require './rest/account/update'
		..put    /\/account\/update_icon(\..+)?$/          require './rest/account/update_icon'
		..put    /\/account\/update_header(\..+)?$/        require './rest/account/update_header'
		..put    /\/account\/update_wallpaper(\..+)?$/     require './rest/account/update_wallpaper'
		..put    /\/account\/update_webtheme(\..+)?$/      require './rest/account/update_webtheme'
		..get    /\/account\/unreadalltalks_count(\..+)?$/ require './rest/account/unreadalltalks_count'
		..delete /\/account\/reset_webtheme(\..+)?$/       require './rest/account/reset_webtheme'
		..post   /\/application\/create(\..+)?$/           require './rest/application/create'
		..post   /\/application\/delete(\..+)?$/           require './rest/application/delete'
		..delete /\/notice\/delete(\..+)?$/                require './rest/notice/delete'
		..delete /\/notice\/deleteall(\..+)?$/             require './rest/notice/deleteall'
		..get    /\/users\/show(\..+)?$/                   require './rest/users/show'
		..post   /\/users\/follow(\..+)?$/                 require './rest/users/follow'
		..delete /\/users\/unfollow(\..+)?$/               require './rest/users/unfollow'
		..post   /\/post\/create(\..+)?$/                  require './rest/post/create'
		..post   /\/post\/favorite(\..+)?$/                require './rest/post/favorite'
		..post   /\/post\/repost(\..+)?$/                  require './rest/post/repost'
		..get    /\/post\/timeline(\..+)?$/                require './rest/post/timeline'
		..post   /\/talk\/say(\..+)?$/                     require './rest/talk/say'
		..put    /\/talk\/fix(\..+)?$/                     require './rest/talk/fix'
		..delete /\/talk\/delete(\..+)?$/                  require './rest/talk/delete'
		..post   /\/talk\/read(\..+)?$/                    require './rest/talk/read'
		..get    /\/search\/user(\..+)?$/                  require './rest/search/user'
		..get    /\/screenname_available(\..+)?$/          require './rest/screenname_available'
		..post   /\/circle\/create(\..+)?$/                require './rest/circle/create'
		..get    /\/circle\/show(\..+)?$/                  require './rest/circle/show'
		..put    /\/circle\/update(\..+)?$/                require './rest/circle/update'
		..all    /\/teapot\/coffee(\..+)?$/                require './rest/teapot/coffee'
