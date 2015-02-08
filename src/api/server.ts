/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import cookie = require('cookie');
import multer = require('multer');
import session = require('express-session');
import redis = require('redis');
import SocketIO = require('socket.io');

import config = require('../config');

import APIResponse = require('./api-response');
import router = require('./router');

var RedisStore: any = require('connect-redis')(session);

var apiServer = express();
var server = require('http').Server(apiServer);
var io = SocketIO(server, {
	origins: 'misskey.xyz:*'
});
server.listen(config.port.api);

apiServer.use(bodyParser.urlencoded({ extended: true }));
apiServer.use(multer());
apiServer.use(cookieParser(config.cookie_pass));
apiServer.use(session({
	key: 'sid',
	secret: 'akaritinatuyuikyouko',
	resave: false,
	saveUninitialized: true,
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

apiServer.use((req: any, res: APIResponse, next: any) => {
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

apiServer.all('*', (req: express.Request, res: express.Response, next: any) => {
	res.set({
		'Access-Control-Allow-Origin': config.publicConfig.url,
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
		'Access-Control-Allow-Credentials': true,
		'X-Frame-Options': 'DENY'
	});
	next();
});

router(apiServer);

io.use((socket: any, next: any) => {
	var handshake = socket.request;
	console.log(handshake);

	if (handshake == null) {
		return next(new Error('[[error:not-authorized]]'));
	}

	if (handshake.headers.cookie != null) {
		var cookies: any = cookie.parse(handshake.headers.cookie);
		console.log(cookies);
		if (cookies.sid != null) {
			console.log(cookies.sid);
			var sessionID = cookies.sid;
			handshake.sessionID = sessionID;
		} else {
			return next(new Error('[[error:not-authorized]]'));
		}
	} else {
		return next(new Error('[[error:not-authorized]]'));
	}
	next();
});

var home = io.of('/streaming/home').on('connection', (socket: any) => {
	console.log(socket.handshake);
	/*if (uid != null) {
		socket.userId = uid;

		var pubsub = redis.createClient();
		pubsub.subscribe('misskey:userStream:' + uid);
		pubsub.on('message', (channel: any, content: any) => {
			socket.emit(JSON.parse(content).type, JSON.parse(content).value);
		});

		socket.on('disconnect', () => {
		});
	}*/
});
