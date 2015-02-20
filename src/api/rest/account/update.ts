/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountUpdate = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		var params = req.body;
		user.name = params.name !== void 0 ? params.name : user.name;
		user.comment = params.comment !== void 0 ? params.comment : user.comment;
		user.badge = params.badge !== void 0 ? params.badge : user.badge;
		user.url = params.url !== void 0 ? params.url : user.url;
		user.location = params.location !== void 0 ? params.location : user.location;
		user.bio = params.bio !== void 0 ? params.bio : user.bio;
		user.tag = params.tag !== void 0 ? params.tag : user.tag;
		user.color = params.color !== void 0 ? params.color.match(/#[a-fA-F0-9]+/) ? params.color : user.color : user.color;
		user.update(() => {
			res.apiRender(user.filt());
		});
	});
}

module.exports = accountUpdate;