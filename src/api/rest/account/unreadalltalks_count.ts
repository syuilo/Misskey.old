/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import TalkMessage = require('../../../models/talk-message');

var authorize = require('../../auth');

function api(req: any, res: APIResponse) {
	authorize(req, res,(user: User, app: Application) => {
		TalkMessage.getAllUnreadCount(user.id,(count: number) => {
			res.apiRender(count);
		});
	});
}

module.exports = api;