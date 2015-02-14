/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import User = require('../../models/user');
import TalkMessage = require('../../models/talk-message');
import Timeline = require('../utils/timeline');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	TalkMessage.getRecentMessagesInRecentTalks(req.me.id, 10,(messages: TalkMessage[]) => {
		res.display(req, res, 'i-talks', {
			messages: messages
		});
	});
};
