/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import User = require('../../../models/user');
import Application = require('../../../models/application');

var authorize = require('../../auth');

function createApplication(req: any, res: APIResponse): void {
	authorize(req, res, (user: User, app: Application) => {
		var name = typeof req.body.name !== 'undefined' ? req.body.name : null;
		var callbackUrl = typeof req.body.callback_url !== 'undefined' ? req.body.callback_url : null;
		var description = typeof req.body.description !== 'undefined' ? req.body.description : null;
		var developerName = typeof req.body.developer_name !== 'undefined' ? req.body.developer_name : null;
		var developerWebsite = typeof req.body.developer_website !== 'undefined' ? req.body.developer_website : null;
		
		if (app.name !== 'Web') {
			res.apiError(403, 'Your application has no permission');
		} else if (name === null || name === '') {
			res.apiError(400, 'name cannot be empty :(');
		} else if (name.length > 32)) {
			res.apiError(400, 'name cannot be more than 32 charactors');
		} else if (callbackUrl === null || callbackUrl === '') {
			res.apiError(400, 'callback_url cannot be empty :(');
		} else if (description === null) {
			res.apiError(400, 'description cannot be empty :(');
		} else if (description.length < 10 || 400 < description.length) {
			res.apiError(400, 'description cannot be less than 10 charactors and more than 400 charactors');
		} else if (developerName === null || developerName === '') {
			res.apiError(400, 'developer_name cannot be empty :(');
		} else if (developerWebsite === null || developerWebsite === '') {
			res.apiError(400, 'developer_website cannot be empty :(');
		} else if (!user.isPremium) {
			Application.findByUserId(user.id, (apps: Application[]) => {
				if (1 <= apps.length) {
					res.apiError(400, 'cannot create application at two or more. need PlusAccount to do so.');
				} else {
					create();
				}
			});
		} else {
			create();
		}
		
		function create() {
			Application.create(name, user.id, callbackUrl, description, developerName, developerWebsite, (createdApp: Application) => {
				if (createdApp == null) {
					res.apiError(500, 'Sorry, register failed.');
				} else {
					res.apiRender(createdApp);
				}
			});
		}
	});
}

export = createApplication;
