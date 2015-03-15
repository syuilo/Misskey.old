/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountResetWebtheme = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		user.webThemeId = null;
		user.update(() => {
			res.apiRender(user.filt());
		});
	});
}

module.exports = accountResetWebtheme;