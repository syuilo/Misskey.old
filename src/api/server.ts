/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import session = require('express-session');

import config = require('../config');

import APIResponse = require('./api-response');
import router = require('./router');

var RedisStore: any = require('connect-redis')(session);

var apiServer = express();

apiServer.use(bodyParser.urlencoded({ extended: true }));
apiServer.use(cookieParser(config.cookie_pass));
apiServer.use(session({
	key: 'sid',
	secret: 'akaritinatuyuikyouko',
	cookie: {
		path: '/',
		domain: '.' + config.publicConfig.domain,
		httpOnly: false,
		secure: false,
		maxAge: null
	},
	store: new RedisStore({
		db: 1,
		prefix: 'misskey-session:'
	})
}));

apiServer.use((req, res: APIResponse, next) => {
	res.apiRender = (data: any) => {
		res.json(data);
	};
	res.apiError = (message: string) => {
		res.json({
			error: {
				message: message
			}
		});
	};
	next();
});

apiServer.all('*', (req: express.Request, res: express.Response, next) => {
	res.set({
		'Access-Control-Allow-Origin': config.publicConfig.url,
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
		'Access-Control-Allow-Credentials': true,
		'X-Frame-Options': 'DENY'
	});
	next();
});

router(apiServer);
apiServer.listen(config.port.api);
