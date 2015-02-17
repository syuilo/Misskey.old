/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountUpdateWebtheme = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		var params = req.body;
		if (params.theme_id == null) {
			res.apiError(400, 'theme_id parameter is required :(');
			return;
		}
		user.webThemeId = params.theme_id;
		user.update(() => {
			res.apiRender(user.filt());
		});
	});
}

module.exports = accountUpdateWebtheme;