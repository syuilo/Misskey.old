/// <reference path="../../../../typings/bundle.d.ts" />

import async = require('async');
import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import Notice = require('../../../models/notice');

var authorize = require('../../auth');

function api(req: any, res: APIResponse) {
	authorize(req, res,(user: User, app: Application) => {
		Notice.findByuserId(user.id,(notices: Notice[]) => {
			async.map(notices,(notice: Notice, next: any) => {
				notice.destroy(() => {
					next(null, null);
				});
			},(err: any, results: any[]) => {
					res.apiRender({
						status: 'success'
					});
				});
		});
	});
}

module.exports = api;