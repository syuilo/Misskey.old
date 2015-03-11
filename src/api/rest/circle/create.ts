/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleCreate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
	});
}
