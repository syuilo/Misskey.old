/// <reference path="../../../../typings/bundle.d.ts" />

import bcrypt = require('bcrypt');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import User = require('../../../models/user');
import UserImage = require('../../../models/user-image');
import UserFollowing = require('../../../models/user-following');
import doLogin = require('../../../web/utils/login');
import Application = require('../../../models/application');
import config = require('../../../config');

var authorize = require('../../auth');

var applicationCreate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {

		if (app.name != 'Web') {
			res.apiError(403, 'access is not allowed :(');
			return;
		}

		if (req.body.name == null) {
			res.apiError(400, 'name parameter is required :(');
			return;
		}
		var name = req.body.name;
		if (!(name != '' && name.length <= 32)) {
			res.apiError(400, 'name invalid format');
			return;
		}

		if (req.body.callback_url == null) {
			res.apiError(400, 'callback_url parameter is required :(');
			return;
		}
		var callbackUrl = req.body.callback_url;
		if (callbackUrl == '') {
			res.apiError(400, 'name invalid format');
			return;
		}

		if (req.body.description == null) {
			res.apiError(400, 'description parameter is required :(');
			return;
		}
		var description = req.body.description;
		if (!(description.length >= 10 && description.length <= 400)) {
			res.apiError(400, 'description invalid format');
			return;
		}

		if (req.body.developer_name == null) {
			res.apiError(400, 'developer_name parameter is required :(');
			return;
		}
		var developerName = req.body.developer_name;
		if (!(developerName != '')) {
			res.apiError(400, 'developer_name invalid format');
			return;
		}

		if (req.body.developer_website == null) {
			res.apiError(400, 'developer_website parameter is required :(');
			return;
		}
		var developerWebsite = req.body.developer_website;
		if (!(developerWebsite != '')) {
			res.apiError(400, 'developer_website invalid format');
			return;
		}

		Application.create(name, user.id, callbackUrl, description, developerName, developerWebsite, (createdApp: Application) => {
			if (createdApp == null) {
				res.apiError(500, 'Sorry, register failed.');
				return;
			}
			res.apiRender(createdApp);
		});
	});
}

module.exports = applicationCreate;
