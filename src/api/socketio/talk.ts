/// <reference path="../../../typings/bundle.d.ts" />

import config = require('../../config');
import session = require('express-session');
import redis = require('redis');
import cookie = require('cookie');
import fs = require('fs');

export = sarver;

var sarver = (io: any, sessionStore: any): void => {
	io.of('/streaming/talk').on('connection',(socket: any) => {
		var cookies: any = cookie.parse(socket.handshake.headers.cookie);
		var sid = cookies[config.sessionKey];

		// Get session
		sessionStore.get(sid.match(/s:(.+?)\./)[1],(err: any, session: any) => {
			if (err) {
				console.log(err.message);
			} else {
				var uid = socket.userId = session.userId;

				socket.emit('connected');

				socket.on('init',(req: any) => {
					var otherpartyId = String(req.otherparty_id);
					socket.otherpartyId = otherpartyId;

					var subscriber = redis.createClient();
					var publisher = redis.createClient();
					subscriber.subscribe('misskey:talkStream:' + uid + '-' + socket.otherpartyId);
					publisher.publish('misskey:talkStream:' + socket.otherpartyId + '-' + uid, 'otherpartyEnterTheTalk');

					subscriber.on('message',(channel: any, content: any) => {
						if (content.type != null && content.value != null) {
							socket.emit(content.type, content.value);
						} else {
							socket.emit(content);
						}
					});

					socket.on('disconnect',() => {
						publisher.publish('misskey:talkStream:' + socket.otherpartyId + '-' + uid, 'otherpartyLeftTheTalk');
					});
				});
			}
		});
	});
};
