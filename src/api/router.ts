/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

export = router;

function router(app: express.Express): void {
	app.post('/account/update', require('./rest/account/update'));
	app.post('/account/update_icon', require('./rest/account/update_icon'));
	app.post('/account/update_header', require('./rest/account/update_header'));
	app.post('/account/update_wallpaper', require('./rest/account/update_wallpaper'));
	app.post('/post/create', require('./rest/post/create'));
};
