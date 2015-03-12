/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import Circle = require('../../../models/circle');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleCreate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		if (req.body.name == null) {
			res.apiError(400, 'name parameter is required :(');
			return;
		}
		if (req.body.screen_name == null) {
			res.apiError(400, 'screen_name is required :(');
			return;
		}
		if (req.body.description == null) {
			res.apiError(400, 'description parameter is required :(');
			return;
		}
		Circle.isScreenNameExist(req.body.screen_name, (exist: boolean) => {
			if (!exist) {
				Circle.create(user.id, req.body.name, req.body.screen_name, req.body.description, (circle: Circle) => {
					res.apiRender(circle);
				});
			} else {
				res.apiError(400, 'that screen_name is exist :(')
			}
		});
	});
}

module.exports = circleCreate;
