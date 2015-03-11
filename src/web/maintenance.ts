/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
import minify = require('express-minify');
import compress = require('compression');

import config = require('../config');

var webServer: any = express();
webServer.disable('x-powered-by');
webServer.set('view engine', 'jade');
webServer.set('views', __dirname + '/views');

/* Compressing settings */
webServer.use(compress());
webServer.use(minify());

/* General rooting */
webServer.all('*',(req: express.Request, res: express.Response, next: () => void) => {
	res.status(503);
	res.render('maintenance');
});

webServer.listen(config.port.web);
