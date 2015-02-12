/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountShow = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		res.apiRender(user.filt());
	});
}

module.exports = accountShow;