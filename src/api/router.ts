/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

export = router;

function router(app: express.Express): void {
	app.all('*',(req: any, res: any, next: any) => {
		var filename = req.url.match(/.+\/(.+?)([\?#;].*)?$/)
		if (filename != null) {
			var extension = filename[1].match(/\.(.+)$/);
			if (extension != null) {
				req.format = extension[1];
			}
		}
		next();
	});
	
	app.get('/authorize', require('./authorize-get'));
	app.post('/authorize',(req: any, res: any) => {
		require('./authorize-post')(req, res, app);
	});

	app.get(/\/sauth\/get_request_token(\..+)?$/, require('./rest/sauth/get_request_token'));
	app.post(/\/account\/create(\..+)?$/, require('./rest/account/create'));
	app.get(/\/account\/show(\..+)?$/, require('./rest/account/show'));
	app.put(/\/account\/update(\..+)?$/, require('./rest/account/update'));
	app.put(/\/account\/update_icon(\..+)?$/, require('./rest/account/update_icon'));
	app.put(/\/account\/update_header(\..+)?$/, require('./rest/account/update_header'));
	app.put(/\/account\/update_wallpaper(\..+)?$/, require('./rest/account/update_wallpaper'));
	app.put(/\/account\/update_webtheme(\..+)?$/, require('./rest/account/update_webtheme'));
	app.get(/\/account\/unreadalltalks_count(\..+)?$/, require('./rest/account/unreadalltalks_count'));
	app.delete(/\/account\/reset_webtheme(\..+)?$/, require('./rest/account/reset_webtheme'));
	app.delete(/\/notice\/delete(\..+)?$/, require('./rest/notice/delete'));
	app.delete(/\/notice\/deleteall(\..+)?$/, require('./rest/notice/deleteall'));
	app.get(/\/users\/show(\..+)?$/, require('./rest/users/show'));
	app.post(/\/users\/follow(\..+)?$/, require('./rest/users/follow'));
	app.delete(/\/users\/unfollow(\..+)?$/, require('./rest/users/unfollow'));
	app.post(/\/post\/create(\..+)?$/, require('./rest/post/create'));
	app.post(/\/post\/favorite(\..+)?$/, require('./rest/post/favorite'));
	app.post(/\/post\/repost(\..+)?$/, require('./rest/post/repost'));
	app.get(/\/post\/timeline(\..+)?$/, require('./rest/post/timeline'));
	app.post(/\/talk\/say(\..+)?$/, require('./rest/talk/say'));
	app.put(/\/talk\/fix(\..+)?$/, require('./rest/talk/fix'));
	app.delete(/\/talk\/delete(\..+)?$/, require('./rest/talk/delete'));
	app.post(/\/talk\/read(\..+)?$/, require('./rest/talk/read'));
	app.get(/\/search\/user(\..+)?$/, require('./rest/search/user'));
	app.get(/\/screenname_available(\..+)?$/, require('./rest/screenname_available'));
	app.post(/\/circle\/create(\..+)?$/, require('./rest/circle/create'));
	app.get(/\/circle\/show(\..+)?$/, require('./rest/circle/show'));
	app.all(/\/teapot\/coffee(\..+)?$/, require('./rest/teapot/coffee'));
};
