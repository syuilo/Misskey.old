/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import Notice = require('../../../models/notice');

var authorize = require('../../auth');

function api(req: any, res: APIResponse) {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.notice_id == null) {
			res.apiError(400, 'notice_id parameter is required :(');
			return;
		}
		var noticeId = req.body.notice_id;

		Notice.find(noticeId,(notice: Notice) => {
			if (notice.userId !== user.id) {
				res.apiError(400, 'Cannot delete The notification which not addressed to you');
				return;
			}
			notice.destroy(() => {
				res.apiRender({
					status: 'success'
				});
			});
		});
	});
}

module.exports = api;