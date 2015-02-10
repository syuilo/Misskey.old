/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import session = require('express-session');
import less = require('less');

import db = require('../db');
import router = require('./routes/index');
import config = require('../config');

var RedisStore: any = require('connect-redis')(session);

var webServer = express();
webServer.set('view engine', 'jade');
webServer.set('views', __dirname + '/views');
//webServer.locals.pretty = '  ';
webServer.use(bodyParser.urlencoded({ extended: true }));
webServer.use(cookieParser(config.cookie_pass));

var year = ((60 * 60 * 24 * 365) * 1000);

webServer.use(session({
	key: config.sessionKey,
	secret: config.sessionSecret,
	resave: false,
	saveUninitialized: true,
	cookie: {
		path: '/',
		domain: '.' + config.publicConfig.domain,
		httpOnly: false,
		secure: false,
		expires: new Date(Date.now() + year),
		maxAge: year
	},
	store: new RedisStore({
		db: 1,
		prefix: 'misskey-session:'
	})
}));

router(webServer);
webServer.listen(config.port.web);
