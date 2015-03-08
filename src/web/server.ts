/// <reference path="../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import async = require('async');
import express = require('express');
import minify = require('express-minify');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import session = require('express-session');
import compress = require('compression');
import Application = require('../models/application');
import User = require('../models/user');
import Notice = require('../models/notice');

import db = require('../db');
import resourcesRouter = require('./routes/resources');
import indexRouter = require('./routes/index');
import config = require('../config');

var RedisStore: any = require('connect-redis')(session);

var webServer: any = express();
webServer.disable('x-powered-by');
webServer.set('view engine', 'jade');
webServer.set('views', __dirname + '/views');
//webServer.locals.pretty = '  ';
webServer.locals.compileDebug = false;
webServer.use(bodyParser.urlencoded({ extended: true }));
webServer.use(cookieParser(config.cookie_pass));

var year = ((60 * 60 * 24 * 365) * 1000);

/* Session settings */
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

/* Compressing settings */
webServer.use(compress());
webServer.use(minify());

webServer.initSession = (req: any, res: any, callback: () => void) => {
	res.set({
		'Access-Control-Allow-Origin': config.publicConfig.url,
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
		'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
		'Access-Control-Allow-Credentials': true,
		'X-Frame-Options': 'SAMEORIGIN'
	});

	/* Is logged */
	req.login = (req.session != null && req.session.userId != null);

	/* Render datas */
	req.data = {};
	req.data.config = config;
	req.data.url = config.publicConfig.url;
	req.data.apiUrl = config.publicConfig.apiUrl;
	req.data.login = req.login;

	/* Renderer function */
	res.display = (req: any, res: any, name: string, renderData: any) => {
		var extend = (destination: any, source: any): Object => {
			for (var k in source) {
				if (source.hasOwnProperty(k)) {
					destination[k] = source[k];
				}
			}
			return destination;
		};

		res.render(name, extend(req.data, renderData));
	};

	if (req.login) {
		var userId = req.session.userId;
		User.find(userId,(user: User) => {
			Notice.findByuserId(user.id,(notices: Notice[]) => {
				if (notices != null) {
					async.map(notices,(notice: any, mapNext: any) => {
						Application.find(notice.appId,(app: Application) => {
							notice.app = app;
							mapNext(null, notice);
						});
					},(err: any, results: any[]) => {
							req.data.notices = results;
							req.data.me = user;
							req.me = user;
							callback();
						});
				} else {
					req.data.me = user;
					req.me = user;
					callback();
				}
			});
		});
	} else {
		req.data.me = null;
		req.me = null;
		callback();
	}
};

/* Statics */
webServer.get('/favicon.ico',(req: any, res: any, next: () => void) => {
	res.sendFile(path.resolve(__dirname + '/resources/favicon.ico'));
});
webServer.get('/manifest.json',(req: any, res: any, next: () => void) => {
	res.sendFile(path.resolve(__dirname + '/resources/manifest.json'));
});

/* Resources rooting */
resourcesRouter(webServer);

/* General rooting */
webServer.all('*',(req: any, res: any, next: () => void) => {
	webServer.initSession(req, res,() => {
		next();
	});
});
indexRouter(webServer);

/* Not found handling */
webServer.use((req, res, next) => {
	res.status(404);
	res.display(req, res, 'notFound', {});
});

/* Error handling */
webServer.use((err, req, res, next) => {
	res.status(500);
	res.display(req, res, 'error', { err: err });
});

webServer.listen(config.port.web);
