/// <reference path="../../typings/bundle.d.ts" />

import AccessToken = require('../models/access-token');
import SauthRequestToken = require('../models/sauth-request-token');
import Application = require('../models/application');
import User = require('../models/user');

var AuthorizeGet = (req: any, res: any) => {
	var login = (req.session != null && req.session.userId != null);
	if (req.query.request_token != null) {
		var requestToken = req.query.request_token;
		SauthRequestToken.find(requestToken,(requestTokenInstance: SauthRequestToken) => {
			if (requestTokenInstance != null) {
				if (!requestTokenInstance.isInvalid) {
					Application.find(requestTokenInstance.appId,(app: Application) => {
						if (login) {
							User.find(req.session.userId,(user: User) => {
								res.render('../web/views/authorize-confirm', {
									login: true,
									me: user,
									app: app
								});
							});
						} else {
							res.render('../web/views/authorize-confirm', {
								login: false,
								app: app,
								loginFailed: false
							});
						}
					});
				} else {
					res.render('../web/views/authorize-invalidToken', {});
				}
			} else {
				res.render('../web/views/authorize-invalidToken', {});
			}
		});
	} else {
		res.apiError(400, 'consumer_key parameter is required :(');
	}
}

module.exports = AuthorizeGet;