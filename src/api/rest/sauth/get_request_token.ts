/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import SauthRequestToken = require('../../../models/sauth-request-token');
import Application = require('../../../models/application');

var SauthGetRequestToken = (req: any, res: APIResponse) => {
	if (req.query.consumer_key != null) {
		var consumerKey = req.query.consumer_key;
		Application.findByConsumerKey(consumerKey,(app: Application) => {
			if (app != null) {
				SauthRequestToken.create(app.id,(requestToken: SauthRequestToken) => {
					res.apiRender({
						token: requestToken.token
					});
				});
			} else {
				res.apiError(404, 'Invalid consumer key :(');
			}
		});
	} else {
		res.apiError(400, 'consumer_key parameter is required :(');
	}
}

module.exports = SauthGetRequestToken;
