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
			if (meMessages == null) meMessages = [];
			if (otherpartyMessages == null) otherpartyMessages = [];
			var messages = meMessages.concat(otherpartyMessages).sort((a, b) => {
				return (a.id < b.id) ? -1 : 1;
			});

			selialyzeTimelineOnject(messages,(serializedMessages: any[]) => {
				res.display(req, res, 'user-talk', {
					otherparty: req.rootUser,
					messages: serializedMessages,
					parseText: Timeline.parseText,
					noHeader: req.query.noheader === 'true'
				});
			});
		});
	});
};

function selialyzeTimelineOnject(talkMessages: TalkMessage[], callback: (talkMessages: any[]) => void): void {
	async.map(talkMessages,(message: any, next: any) => {
		User.find(message.userId,(user: User) => {
			message.user = user;
			Application.find(message.appId,(app: Application) => {
				message.app = app;
				User.find(message.otherpartyId,(otherparty: User) => {
					message.otherparty = otherparty;
					next(null, message);
				});
			});
		});
	},(err: any, results: any[]) => {
			callback(results);
		});
}