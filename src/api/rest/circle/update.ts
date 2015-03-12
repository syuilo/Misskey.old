/// <reference path="../../../../typings/bundle.d.ts" />

import Application = require('../../../models/application');
import APIResponse = require('../../api-response');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleUpdate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		
	});
}

module.exports = circleUpdate;
