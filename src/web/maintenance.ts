/// <reference path="../../typings/bundle.d.ts" />

import jade = require('jade');
import express = require('express');
import minify = require('express-minify');
import compress = require('compression');

import config = require('../config');

var webServer: any = express();
webServer.disable('x-powered-by');

/* Compressing settings */
webServer.use(compress());
webServer.use(minify());

/* Precompile */
var message = jade.renderFile(__dirname + '/views/maintenance.jade');

/* General routing */
webServer.all('*',(req: express.Request, res: express.Response, next: () => void) => {
	res.status(503);
	res.send(message);
});

webServer.listen(config.port.web);
