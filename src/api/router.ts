/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

export = router;

function router(app: express.Express): void {
	app.post('/account/update', require('./rest/account/update'));
	app.post('/post/create', require('./rest/post/create'));
};
