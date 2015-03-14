/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var showPost = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		if (req.query.post_id == null) {
			res.apiError(400, 'post_id parameter is required :(');
			return;
		}
	});
}

module.exports =showPost;
