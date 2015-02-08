/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import session = require('express-session');
import cookie = require('cookie');
import fs = require('fs');

import https = require('https');
var server = https.createServer({
	key: fs.readFileSync('../../../../certs/server.key').toString(),
	cert: fs.readFileSync('../../../../certs/startssl.crt').toString(),
	ca: fs.readFileSync('../../../../certs/sub.class1.server.ca.pem').toString()
},
	(req: any, res: any) => {
		res.writeHead(200, { "Content-Type": "text/plain" });
		var output = 'kyoppie';
		res.end(output);
	}).listen(1207);

import SocketIO = require('socket.io');
var io = SocketIO.listen(server, {
	origins: 'misskey.xyz:*'
});

import redis = require('redis');
var RedisStore: any = require('connect-redis')(session);
var sessionStore = new RedisStore({
	db: 1,
	prefix: 'misskey-session:'
});

/* Authorization */
io.use((socket: any, next: any) => {
	var handshake = socket.request;

	if (handshake == null) {
		return next(new Error('[[error:not-authorized]]'));
	}

	if (handshake.headers.cookie != null) {
		var cookies: any = cookie.parse(handshake.headers.cookie);
		if (cookies[config.sessionKey] != null) {
			if (cookies[config.sessionKey].match(/s:(.+?)\./)) {
				next();
			} else {
				return next(new Error('[[error:not-authorized]]'));
			}
		} else {
			return next(new Error('[[error:not-authorized]]'));
		}
	} else {
		return next(new Error('[[error:not-authorized]]'));
	}
});

/* Home stream */
var home = io.of('/streaming/home').on('connection', (socket: any) => {
	var cookies: any = cookie.parse(socket.handshake.headers.cookie);
	var sid = cookies[config.sessionKey];

	// Get session
	sessionStore.get(sid.match(/s:(.+?)\./)[1], (err: any, session: any) => {
		if (err) {
			console.log(err.message);
		} else {
			var uid = socket.userId = session.userId;

			// Subscribe stream
			var pubsub = redis.createClient();
			pubsub.subscribe('misskey:userStream:' + uid);
			pubsub.on('message', (channel: any, content: any) => {
				// Sent event
				socket.emit(JSON.parse(content).type, JSON.parse(content).value);
			});

			socket.on('disconnect', () => {
			});
		}
	});
});
