/// <reference path="../../../typings/bundle.d.ts" />

import config = require('../../config');
import session = require('express-session');
import redis = require('redis');
import cookie = require('cookie');
import fs = require('fs');

export = sarver;

var sarver = (io: any, sessionStore: any): void => {
	io.of('/streaming/home').on('connection',(socket: any) => {
		var cookies: any = cookie.parse(socket.handshake.headers.cookie);
		var sid = cookies[config.sessionKey];

		// Get session
		sessionStore.get(sid.match(/s:(.+?)\./)[1],(err: any, session: any) => {
			if (err) {
				console.log(err.message);
			} else {
				var uid = socket.userId = session.userId;

				// Subscribe stream
				var pubsub = redis.createClient();
				pubsub.subscribe('misskey:userStream:' + uid);
				pubsub.on('message',(channel: any, content: any) => {
					// Sent event
					socket.emit(JSON.parse(content).type, content.value);
				});

				socket.on('disconnect',() => {
				});
			}
		});
	});
};
