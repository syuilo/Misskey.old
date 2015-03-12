/// <reference path="../../../../typings/bundle.d.ts" />

import Application = require('../../../models/application');
import APIResponse = require('../../api-response');
import Circle = require('../../../models/circle');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleUpdate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		var params = req.body;
		if (params.circle_id == null) {
			res.apiError(400, 'circle_id parameter is required :(');
			return;
		}
		Circle.find(params.circle_id, (circle: Circle) => {
			if (circle != null) {
				if (params.name != null) {
					circle.name = params.name;
				}
				if (params.description != null) {
					circle.description = params.description;
				}
			} else {
				res.apiError(404, 'Not found that circle :(');
				return;
			}
		});
	});
}

module.exports = circleUpdate;
