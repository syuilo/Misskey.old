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
		user.name = params.name != null ? params.name : user.name;
		user.comment = params.comment != null ? params.comment : user.comment;
		user.badge = params.badge != null ? params.badge : user.badge;
		user.url = params.url != null ? params.url : user.url;
		user.location = params.location != null ? params.location : user.location;
		user.bio = params.bio != null ? params.bio : user.bio;
		user.tag = params.tag != null ? params.tag : user.tag;
		user.color = params.color != null ? params.color.match(/#[a-fA-F0-9]+/) ? params.color : user.color : user.color;
		user.update(() => {
			res.apiRender(user.filt());
		});
	});
}

module.exports = accountUpdate;