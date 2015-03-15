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
		var name = req.body.name;
		if (req.body.screen_name == null) {
			res.apiError(400, 'screen_name is required :(');
			return;
		}
		var screenName = req.body.screen_name;
		if (!validateScreenName(screenName)) {
			res.apiError(400, 'screen_name invalid format :(');
			return;
		}
		function validateScreenName(screenName: string) {
			return 4 <= screenName.length &&
				screenName.length <= 20 &&
				!screenName.match(/^[0-9]+$/) &&
				screenName.match(/^[a-zA-Z0-9_]+$/);
		}
		if (req.body.description == null) {
			res.apiError(400, 'description parameter is required :(');
			return;
		}
		var description = req.body.description;
		Circle.existScreenName(screenName, (exist: boolean) => {
			if (!exist) {
				Circle.create(user.id, name, screenName, description, (circle: Circle) => {
					res.apiRender(circle);
				});
			} else {
				res.apiError(400, 'that screen_name is exist :(')
			}
		});
	});
}

module.exports = circleCreate;
