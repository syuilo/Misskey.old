/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

import config = require('../config');

import APIResponse = require('./api-response');
import AccessToken = require('../models/access-token');
import Application = require('../models/application');
import User = require('../models/user');

export = authorize;

var authorize = (req: Express.Request, success: (user: User, app: Application) => void, fail: () => void): void  => {
	var isLogged = (req.session != null && req.session.userId != null);
	var consumerKey = req.param('consumer_key');
	var accessToken = req.param('access_token');

	if (consumerKey == null || accessToken == null) {
		if (req.header('Referer') === config.publicConfig.url || req.header('Referer') === config.publicConfig.url + '/') {
			if (isLogged) {
				if (req.session.consumerKey != null && req.session.accessToken != null) {
					consumerKey = req.session.consumerKey;
					accessToken = req.session.accessToken;
				} else {
					fail();
					return;
				}
			} else {
				fail();
				return;
			}
		} else {
			fail();
			return;
		}
	}

	AccessToken.find(accessToken, (accessTokenInstance: AccessToken) => {
		if (accessTokenInstance != null) {
			Application.findByConsumerKey(consumerKey, (application: Application) => {
				if (application != null) {
					if (accessTokenInstance.appId === application.id) {
						User.find(accessTokenInstance.userId, (user: User) => {
							if (user != null) {
								success(user, application);
							} else {
								fail();
							}
						});
					} else {
						fail();
					}
				} else {
					fail();
				}
			});
		} else {
			fail();
		}
	});
};
