/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');

import config = require('../config');

import APIResponse = require('./api-response');
import AccessToken = require('../models/access-token');
import Application = require('../models/application');
import User = require('../models/user');

export = authorize;

var authorize = (req: any, res: APIResponse, success: (user: User, app: Application) => void): void  => {
	var isLogged = (req.session != null && req.session.userId != null);

	if (req.method === 'GET') {
		var consumerKey = req.query.consumer_key;
		var accessToken = req.query.access_token;
	} else {
		var consumerKey = req.body.consumer_key;
		var accessToken = req.body.access_token;
	}
	
	var fail = (message: string): void => {
		res.apiRender({ error: message });
		return;
	};

	if (consumerKey == null || accessToken == null) {
		if (req.header('Referer') === config.publicConfig.url || req.header('Referer') === config.publicConfig.url + '/') {
			if (isLogged) {
				if (req.session.consumerKey != null && req.session.accessToken != null) {
					consumerKey = req.session.consumerKey;
					accessToken = req.session.accessToken;
				} else {
					fail('You are logged in, but, CK or CS has not been set.');
					return;
				}
			} else {
				fail('not logged');
				return;
			}
		} else {
			fail('CK or CS is null and empty Referer');
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
								fail('Bad request');
							}
						});
					} else {
						fail('Bad request');
					}
				} else {
					fail('Bad request');
				}
			});
		} else {
			fail('Bad request');
		}
	});
};
