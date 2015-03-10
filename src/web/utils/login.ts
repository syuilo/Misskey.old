/// <reference path="../../../typings/bundle.d.ts" />

import express = require('express');
import AccessToken = require('../../models/access-token');
import User = require('../../models/user');
import Notice = require('../../models/notice');
import bcrypt = require('bcrypt');
import config = require('../../config');

export = login;

function login(req: any, screenName: string, password: string, done: (user: User, webAccessToken: AccessToken) => void, fail: () => void): void {
	if (screenName == '' || password == '') {
		fail();
	} else {
		User.findByScreenName(screenName,(user: User) => {
			if (user == null) {
				fail();
			} else {
				var dbPassword = user.password.replace('$2y$', '$2a$');
				bcrypt.compare(password, dbPassword,(err: any, same: boolean) => {
					if (same) {
						AccessToken.findByUserIdAndAppId(user.id, config.webClientId,(webAccessToken: AccessToken) => {
							Notice.create(config.webClientId, 'login', 'ログインしました。', user.id,(notice: Notice) => {
								req.session.userId = user.id;
								req.session.consumerKey = config.webClientConsumerKey;
								req.session.accessToken = webAccessToken.token;
								req.session.save(() => done(user, webAccessToken));
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