/// <reference path="../../typings/bundle.d.ts" />

import AccessToken = require('../models/access-token');
import SauthRequestToken = require('../models/sauth-request-token');
import SauthPinCode = require('../models/sauth-pincode');
import Application = require('../models/application');
import User = require('../models/user');
import doLogin = require('../web/utils/login');

function AuthorizePost(req: any, res: any, server: any): void {
	var login = (req.session != null && req.session.userId != null);
	var requestToken = typeof req.query.request_token !== 'undefined' ? req.query.request_token : null;
	var screenName = typeof req.body.screen_name !== 'undefined' ? req.body.screen_name : null;
	var password = typeof req.body.password !== 'undefined' ? req.body.password : null;
	if (requestToken !== null) {
		SauthRequestToken.find(requestToken, (requestTokenInstance: SauthRequestToken) => {
			if (requestTokenInstance != null && !requestTokenInstance.isInvalid) {
				Application.find(requestTokenInstance.appId, (app: Application) => {
					if (screenName !== null && password !== null) {
						doLogin(server, screenName, password, (user: User, webAccessToken: AccessToken) => {
							validate(requestTokenInstance, user, app);
						}, renderConfirmation);
					} else if (login) {
						User.find(req.session.userId, (user: User) => {
							validate(requestTokenInstance, user, app);
						});
					} else {
						renderConfirmation();
					}
				})
			}
		});
	}
	
	function validate(requestTokenInstance: SauthRequestToken, user: User, app: Application): void {
		if (req.body.cancel != null) {
			requestTokenInstance.isInvalid = true;
			requestTokenInstance.update();
			renderCancel();
		} else {
			SauthPinCode.create(app.id, user.id, (pincode: SauthPinCode) => {
				if (app.callbackUrl === '') {
					renderSuccess();
				} else {
					res.redirect(app.callbackUrl + '?pincode=' + pincode.code);
				}
			});
		}
	}
	
	function renderConfirmation(): void {
		res.render('../web/views/authorize-confirm', {
			login: false,
			app: app,
			loginFailed: false
		});
	}

	function renderCancel(): void {
		res.render('../web/views/authorize-cancel', {
			login: true,
			app: app,
			me: user
		});
	}
	
	function renderSuccess(): void {
		res.render('../web/views/authorize-success', {
			login: true,
			me: user,
			app: app,
			code: pincode.code
		});
	}
}

export = AuthorizePost;
