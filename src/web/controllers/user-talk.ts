/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import User = require('../../models/user');
import TalkMessage = require('../../models/talk-message');
import Timeline = require('../utils/timeline');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	TalkMessage.findByUserIdAndOtherpartyId(req.me.id, req.rootUser.id, 16, null, null,(meMessages: TalkMessage[]) => {
		TalkMessage.findByUserIdAndOtherpartyId(req.rootUser.id, req.me.id, 16, null, null,(otherpartyMessages: TalkMessage[]) => {
			var messages = meMessages.concat(otherpartyMessages).sort((a, b) => {
				return (a.id > b.id) ? -1 : 1;
			});

			res.display(req, res, 'user-talk', {
				otherparty: req.rootUser,
				messages: messages
			});
		});
	});
};
