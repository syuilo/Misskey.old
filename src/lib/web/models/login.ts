/// <reference path="../../../../typings/bundle.d.ts" />

import express = require('express');
import User = require('../../model/user');
import Notice = require('../../model/notice');
import bcrypt = require('bcrypt');
import redis = require('redis');

export = login;

function login(app: express.Express, screenName: string, password: string, done: (user: User) => void, fail: () => void): void {
	var config = app.get("config");
	var subscriber = redis.createClient(config.port.redis, 'localhost');
	if (screenName == '' || password == '') {
		fail();
	} else {
		User.findByScreenName(screenName, (user: User) => {
			if (user == null) {
				fail();
			} else {
				var dbPassword = user.password.replace('$2y$', '$2a$');
				bcrypt.compare(password, dbPassword, (err: any, same: boolean) => {
					if (same) {
						Notice.create(config.webClientId, 'ログインしました。', user.id, (notice: Notice) => {
							var noticeData: any = {};
							noticeData['data'] = notice;
							noticeData['type'] = 'notice';
							subscriber.publish('misskey:userstream', JSON.stringify(noticeData));
							done(user);
						});
					} else {
						fail();
					}
				});
			}
		});
	}
}