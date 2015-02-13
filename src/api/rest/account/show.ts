/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountShow = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		res.apiRender(user.filt());
	});
}

module.exports = accountShow;