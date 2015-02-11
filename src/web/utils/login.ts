/// <reference path="../../../typings/bundle.d.ts" />

import express = require('express');
import AccessToken = require('../../models/access-token');
import User = require('../../models/user');
import Notice = require('../../models/notice');
import bcrypt = require('bcrypt');
import redis = require('redis');
import config = require('../../config');

export = login;

function login(app: express.Express, screenName: string, password: string, done: (user: User, webAccessToken: AccessToken) => void, fail: () => void): void {
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
						AccessToken.findByUserIdAndAppId(user.id, config.webClientId, (webAccessToken: AccessToken) => {
							Notice.create(config.webClientId, 'ログインしました。', user.id, (notice: Notice) => {
								var noticeData: any = {};
								noticeData['data'] = notice;
								noticeData['type'] = 'notice';
								subscriber.publish('misskey:userstream', JSON.stringify(noticeData));
								done(user, webAccessToken);
							});
						});
					} else {
						fail();
					}
				});
			}
		});
	}
}