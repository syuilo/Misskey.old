/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

export = router;

function router(app: express.Express): void {
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
