/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import cookie = require('cookie');
import multer = require('multer');
import session = require('express-session');
import redis = require('redis');
import yaml = require('js-yaml');

import config = require('../config');

import APIResponse = require('./api-response');
import router = require('./router');

var RedisStore: any = require('connect-redis')(session);

var apiServer = express();
apiServer.disable('x-powered-by');
var server = require('http').Server(apiServer);

server.listen(config.port.api);

var sessionStore = new RedisStore({
	db: 1,
	prefix: 'misskey-session:'
});
apiServer.use(bodyParser.urlencoded({ extended: true }));
apiServer.use(multer());
apiServer.use(cookieParser(config.cookie_pass));
apiServer.use(session({
	key: config.sessionKey,
	secret: config.sessionSecret,
	resave: false,
	saveUninitialized: true,
	cookie: {
		path: '/',
		domain: '.' + config.publicConfig.domain,
		httpOnly: false,
		secure: false,
		maxAge: null
	},
	store: sessionStore
}));

apiServer.use((req: any, res: APIResponse, next: any) => {
	res.apiRender = (data: any) => {
		if (req.format == null) {
			res.json(data);
		} else {
			switch (req.format) {
				case 'json':
					res.json(data);
					break;
				case 'yaml':
					res.send(yaml.safeDump(data));
					break;
				default:
					res.json(data);
					break;
			}
		}
	};
	res.apiError = (code: number, message: string) => {
		res.status(code);
		res.json({
			error: {
				message: message
			}
		});
	};
	next();
});

apiServer.all('*', (req: express.Request, res: express.Response, next: any) => {
	res.set({
		'Access-Control-Allow-Origin': config.publicConfig.url,
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
		'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
		'Access-Control-Allow-Credentials': true,
		'X-Frame-Options': 'DENY'
	});
	next();
});

router(apiServer);

require('./streaming-server');