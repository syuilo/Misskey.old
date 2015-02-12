/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import AccessToken = require('../models/access-token');
import redis = require('redis');

var publisher = redis.createClient(config.redis.port, config.redis.host);

export = AccessTokenManager;

class AccessTokenManager {
	public static create(userId: number, appId: number, fail: () => void, success: (accessToken: AccessToken) => void) {
		AccessToken.findByUserIdAndAppId(userId, appId,(at: AccessToken) => {
			if (at == null) {
				AccessToken.create(appId, userId,(accessTokenInstance: AccessToken) => {
					success(accessTokenInstance);
				});
			} else {
				fail();
			}
		});
	}
}