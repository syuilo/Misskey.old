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
		}
		if (req.body.description == null) {
			res.apiError(400, 'description parameter is required :(');
		}
		Circle.create(user.id, req.body.name, req.body.description, (circle: Circle) => {
			res.apiRender(circle);
		});
	});
}
