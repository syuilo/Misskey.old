/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import Circle = require('../../../models/circle');
import User  = requier('../../../models/user');

var authorize = require('../../auth');

var circleDelete = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		if (req.body.circle_id == null) {
			res.apiError(400, 'circle_id parameter is required :(');
			return;
		}
		var circleId = req.body.circle_id;
		Circle.find(circleId, (circle: Circle) => {
			if (circle == null) {
				res.apiError(404, 'Not found that circle :(');
				return;
			}
		});
	});
}

module.exports = circleDelete;
