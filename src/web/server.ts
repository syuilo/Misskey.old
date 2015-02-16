/// <reference path="../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import express = require('express');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import session = require('express-session');
import compress = require('compression');
import less = require('less');
import User = require('../models/user');

import db = require('../db');
import router = require('./routes/index');
import config = require('../config');

var RedisStore: any = require('connect-redis')(session);

var webServer = express();
webServer.disable('x-powered-by');
webServer.set('view engine', 'jade');
webServer.set('views', __dirname + '/views');
//webServer.locals.pretty = '  ';
webServer.use(compress());
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

function sentLess(req: any, res: any, resourcePath: string, styleUser: User) {
	fs.readFile(resourcePath, 'utf8',(err: NodeJS.ErrnoException, lessCss: string) => {
		if (err) throw err;
		lessCss = lessCss.replace(/<%themeColor%>/g, styleUser != null ? styleUser.color : '#831c86');
		lessCss = lessCss.replace(/<%wallpaperUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/wallpaper/${styleUser.screenName}"` : '');
		lessCss = lessCss.replace(/<%headerImageUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/header/${styleUser.screenName}"` : '');
		lessCss = lessCss.replace(/<%headerBlurImageUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/header/${styleUser.screenName}?blur=64"` : '');
		less.render(lessCss, { compress: true },(err: any, output: any) => {
			if (err) throw err;
			res.header("Content-type", "text/css");
			res.send(output.css);
		});
	});
}

function initSession(req: any, res: any, callback: () => void) {
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
	res.display = display;

	if (req.login) {
		var userId = req.session.userId;
		User.find(userId,(user: User) => {
			req.data.me = user;
			req.me = user;
			callback();
		});
	} else {
		req.data.me = null;
		req.me = null;
		callback();
	}
}

var display = (req: any, res: any, name: string, renderData: any) => {
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

webServer.get(/^\/resources\/.*/,(req: any, res: any, next: () => void) => {
	req.url = req.url.replace(/\?.*/, '');
	if (req.url.indexOf('..') === -1) {
		if (req.url.match(/\.css$/)) {
			var resourcePath = path.resolve(__dirname + '/..' + req.url.replace(/\.css$/, '.less'));
			if (fs.existsSync(resourcePath)) {
				initSession(req, res,() => {
					if (req.login) {
						if (req.query.user == null) {
							sentLess(req, res, resourcePath, req.me);
						} else {
							User.findByScreenName(req.query.user,(styleUser: User) => {
								if (styleUser != null) {
									sentLess(req, res, resourcePath, styleUser);
								} else {
									sentLess(req, res, resourcePath, null);
								}
							});
						}
					} else {
						sentLess(req, res, resourcePath, null);
					}
				});
				return;
			}
		}
		if (req.url.indexOf('.less') === -1) {
			var resourcePath = path.resolve(__dirname + '/..' + req.url);
			res.sendFile(resourcePath);
		} else {
			next();
		}
	}
});

webServer.all('*',(req: any, res: any, next: () => void) => {
	initSession(req, res,() => {
		next();
	});
});

router(webServer);
webServer.listen(config.port.web);
