/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import SauthRequestToken = require('../../../models/sauth-request-token');
import Application = require('../../../models/application');

function getRequestToken(req: any, res: APIResponse): void {
	var consumerKey = typeof req.query.consumer_key !== 'undefined' ? req.query.consumer_key : null;
	if (consumerKey !== null) {
		Application.findByConsumerKey(consumerKey, (app: Application) => {
			if (app != null) {
				SauthRequestToken.create(app.id, (requestToken: SauthRequestToken) => {
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

export = getRequestToken;
