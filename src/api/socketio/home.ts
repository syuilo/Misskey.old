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
		var sidkey = sid.match(/s:(.+?)\./)[1];
		sessionStore.get(sidkey,(err: any, session: any) => {
			if (err) {
				console.log(err.message);
			} else {
				if (session == null) {
					console.log('undefined: ' + sidkey);
					return;
				}

				var uid = socket.userId = session.userId;

				// Subscribe stream
				var pubsub = redis.createClient();
				pubsub.subscribe('misskey:userStream:' + uid);
				pubsub.on('message',(channel: any, content: any) => {
					content = JSON.parse(content);
					if (content.type != null && content.value != null) {
						socket.emit(content.type, content.value);
					} else {
						socket.emit(content);
					}
				});

				socket.on('disconnect',() => {
				});
			}
		});
	});
};
