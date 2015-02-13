/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var usersShow = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.user_id == null) {
			res.apiError(400, 'user_id parameter is required :(');
			return;
		}
		var userId = req.body.user_id;

		User.find(userId,(targetUser: User) => {
			if (targetUser != null) {
				res.apiRender(targetUser.filt());
			} else {
				res.apiError(404, 'User not found...');
			}
		});
	});
}

module.exports = usersShow;