/// <reference path="../../typings/bundle.d.ts" />

import AccessToken = require('../models/access-token');
import SauthRequestToken = require('../models/sauth-request-token');
import SauthPinCode = require('../models/sauth-pincode');
import Application = require('../models/application');
import User = require('../models/user');
import doLogin = require('../web/utils/login');

var AuthorizePost = (req: any, res: any, server: any) => {
	var login = (req.session != null && req.session.userId != null);
	if (req.query.request_token != null) {
		var requestToken = req.query.request_token;
		SauthRequestToken.find(requestToken,(requestTokenInstance: SauthRequestToken) => {
			if (requestTokenInstance != null) {
				if (requestTokenInstance.isInvalid) {
					return;
				}
				Application.find(requestTokenInstance.appId,(app: Application) => {
					if (req.body.screen_name != null && req.body.password != null) {
						doLogin(server, req, req.body.screen_name, req.body.password,(user: User, webAccessToken: AccessToken) => {
							validate(requestTokenInstance, user, app);
						},() => {
								res.render('../web/views/authorize-confirm', {
									login: false,
									app: app,
									loginFailed: true
								});
							});
					} else {
						if (login) {
							User.find(req.session.userId,(user: User) => {
								validate(requestTokenInstance, user, app);
							});
						} else {
							res.render('../web/views/authorize-confirm', {
								login: false,
								app: app,
								loginFailed: false
							});
						}
					}
				});
			} else {

			}
		});
	} else {

	}

	var validate = (requestTokenInstance: SauthRequestToken, user: User, app: Application) => {
		if (req.body.cancel != null) {
			requestTokenInstance.isInvalid = true;
			requestTokenInstance.update();
			res.render('../web/views/authorize-cancel', {
				login: true,
				app: app,
				me: user
			});
		} else {
			SauthPinCode.create(app.id, user.id,(pincode: SauthPinCode) => {
				if (app.callbackUrl == '') {
					res.render('../web/views/authorize-success', {
						login: true,
						me: user,
						app: app,
						code: pincode.code
					});
				} else {
					res.redirect(app.callbackUrl + '?pincode=' + pincode.code);
				}
			});
		}
	};
}

module.exports = AuthorizePost;