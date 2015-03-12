/// <reference path="../../../../typings/bundle.d.ts" />

import Application = require('../../../models/application');
import APIResponse = require('../../api-response');
import Circle = require('../../../models/circle');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleUpdate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		var param = req.body;
		if (param.circle_id == null) {
			res.apiError(400, 'circle_id parameter is required :(');
			return;
		}
	});
}

module.exports = circleUpdate;
