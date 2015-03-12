/// <reference path="../../../../typings/bundle.d.ts" />

import Application = require('../../../models/application');
import APIResponse = require('../../api-response');
import Circle = require('../../../models/circle');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleShow = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		if (req.query.circle_id == null) {
			res.apiError(400, 'circle_id is required :(');
			return;
		}
		Circle.find(req.query.circle_id, (circle: Circle) => {
			if (circle != null) {
				res.apiRender(circle);
			} else {
				res.apiError(404, 'Not found that circle :(');
				return;
			}
		});
	});
}

module.exports = circleShow;
