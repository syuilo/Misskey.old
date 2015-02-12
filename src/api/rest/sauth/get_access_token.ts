/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import SauthRequestToken = require('../../../models/sauth-request-token');
import SauthPinCode = require('../../../models/sauth-pincode');
import Application = require('../../../models/application');
import AccessTokenManager = require('../../../utils/access-token');

var SauthGetAccessToken = (req: any, res: APIResponse) => {
	if (req.query.consumer_key == null) {
		res.apiError(400, 'consumer_key parameter is required :(');
		return;
	}
	var consumerKey = req.query.consumer_key;

	if (req.query.request_token == null) {
		res.apiError(400, 'request_token parameter is required :(');
		return;
	}
	var requestToken = req.query.request_token;

	if (req.query.pincode == null) {
		res.apiError(400, 'pincode parameter is required :(');
		return;
	}
	var pincode = req.query.pincode;

	Application.findByConsumerKey(consumerKey,(app: Application) => {
		if (app == null) {
			res.apiError(404, 'Invalid consumer key :(');
			return;
		}
		SauthRequestToken.find(requestToken,(requestTokenInstance: SauthRequestToken) => {
			if (requestTokenInstance == null) {
				res.apiError(404, 'Invalid request token :(');
				return;
			}
			if (requestTokenInstance.appId !== app.id) {
				res.apiError(400, 'Invalid token :(');
				return;
			}
			SauthPinCode.find(pincode,(pincodeInstance: SauthPinCode) => {
				if (pincodeInstance == null) {
					res.apiError(404, 'Invalid pincode :(');
					return;
				}
				if (pincodeInstance.appId !== app.id) {
					res.apiError(400, 'Invalid pincode :(');
					return;
				}

				pincodeInstance.destroy();
				requestTokenInstance.destroy();
				AccessTokenManager.create(pincodeInstance.userId, app.id,() => {

				},(accessToken: AccessToken) => {
						res.apiRender({
							'access_token': accessToken.token
						});
					});
			});
		});
	});
}

module.exports = SauthGetAccessToken;