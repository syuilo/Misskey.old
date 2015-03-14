/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import User = require('../../../models/user');
import Application = require('../../../models/application');

var validateArguments: (
	app: Application,
	name: string,
	callbackUrl: string,
	description: string,
	developerName: string,
	developerWebsite: string
) => [number, string] = require('./create/validate-arguments');

var authorize = require('../../auth');

function createApplication(req: any, res: APIResponse): void {
	authorize(req, res, (user: User, app: Application) => {
		var name: string = typeof req.body.name !== 'undefined' ? req.body.name : null;
		var callbackUrl: string = typeof req.body.callback_url !== 'undefined' ? req.body.callback_url : null;
		var description: string = typeof req.body.description !== 'undefined' ? req.body.description : null;
		var developerName: string = typeof req.body.developer_name !== 'undefined' ? req.body.developer_name : null;
		var developerWebsite: string = typeof req.body.developer_website !== 'undefined' ? req.body.developer_website : null;
		
		var error = validateArguments(app, name, callbackUrl, description, developerName, developerWebsite);
		if (error !== null) {
			res.apiError(error[0], error[1]);
		} else if (!user.isPremium) {
			hasAppOneOrMore(oneOrMore => {
				if (oneOrMore) {
					res.apiError(400, 'cannot create application at two or more. need PlusAccount to do so.');
				} else {
					create();
				}
			});
		} else {
			create();
		}
		
		function hasAppOneOrMore(callback: (oneOrMore: boolean) => void): void {
			Application.findByUserId(user.id, (apps: Application[]) => callback(1 <= apps.length));
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
