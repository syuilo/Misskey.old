/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

export = router;

function router(app: express.Express): void {
	app.post('/post/create', require('./rest/post/create'));
};
