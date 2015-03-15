/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import User = require('../../../models/user');
import Application = require('../../../models/application');

import config = require('../config');

var authorize = require('../../auth');

var applicationDelete = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {

		if (app.id != config.webClientId) {
			res.apiError(403, 'access is not allowed :(');
			return;
		}

		if (req.body.id == null) {
			res.apiError(400, 'id parameter is required :(');
			return;
		}
		var id = req.body.id;
		if (id == '') {
			res.apiError(400, 'id invalid format');
			return;
		}

		Application.find(id, (app: Application) => {
			if (app == null) {
				res.apiError(400, 'Application not found.');
				return;
			}
			app.destroy(() => {
				res.apiRender({
					status: 'success'
				});
			});
		});
	});
}

module.exports = applicationDelete;
