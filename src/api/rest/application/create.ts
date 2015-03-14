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
		
		var error = validateArguments();
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
		
		function validateArguments(): [number, string] {
			switch(true) {
				case app.name !== 'Web':
					return [403, 'Your application has no permission'];
				case isNullOrEmpty(name):
					return [400, 'name cannot be empty :('];
				case name.length > 32:
					return [400, 'name cannot be more than 32 charactors'];
				case isNullOrEmpty(callbackUrl):
					return [400, 'callback_url cannot be empty :('];
				case description === null:
					return [400, 'description cannot be empty :('];
				case description.length < 10 || 400 < description.length:
					return [400, 'description cannot be less than 10 charactors and more than 400 charactors'];
				case isNullOrEmpty(developerName):
					return [400, 'developer_name cannot be empty :('];
				case isNullOrEmpty(developerWebsite):
					return [400, 'developer_website cannot be empty :('];
				default:
					return null;
			}
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

function isNullOrEmpty(obj: string): boolean {
	return obj === null || obj === '';
}

export = createApplication;
