/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

export = router;

function router(app: express.Express): void {
	/*app.all('*',(req: any, res: any) => {
		req.url.match(".+/(.+?)([\?#;].*)?$")[1]
	});*/

	app.get('/authorize', require('./authorize-get'));
	app.post('/authorize',(req: any, res: any) => {
		require('./authorize-post')(req, res, app);
	});

	app.get('/sauth/get_request_token', require('./rest/sauth/get_request_token'));
	app.get('/account/show', require('./rest/account/show'));
	app.put('/account/update', require('./rest/account/update'));
	app.put('/account/update_icon', require('./rest/account/update_icon'));
	app.put('/account/update_header', require('./rest/account/update_header'));
	app.put('/account/update_wallpaper', require('./rest/account/update_wallpaper'));
	app.get('/users/show', require('./rest/users/show'));
	app.post('/users/follow', require('./rest/users/follow'));
	app.delete('/users/unfollow', require('./rest/users/unfollow'));
	app.post('/post/create', require('./rest/post/create'));
	app.all('/teapot/coffee', require('./rest/teapot/coffee'));
};
