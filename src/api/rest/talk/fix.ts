/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import TalkMessage = require('../../../models/talk-message');
var authorize = require('../../auth');

module.exports = talkFix;

function talkFix(req: any, res: APIResponse) {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.text == null) {
			res.apiError(400, 'text parameter is required :(');
			return;
		}
		var text = req.body.text;

		if (req.body.message_id == null) {
			res.apiError(400, 'message_id parameter is required :(');
			return;
		}
		var messageId = req.body.message_id;

		TalkMessage.find(messageId,(talkMessage: TalkMessage) => {
			if (talkMessage == null) {
				res.apiError(400, 'Message not found.');
				return;
			}

			if (talkMessage.isDeleted) {
				res.apiError(400, 'This message has already been deleted.');
				return;
			}

			talkMessage.text = text;
			talkMessage.update(() => {
				TalkMessage.buildResponseObject(talkMessage,(obj: any) => {
					// Sent response
					res.apiRender(obj);

					// Other party
					Streamer.publish('talkStream:' + talkMessage.otherpartyId + '-' + user.id, JSON.stringify({
						type: 'otherpartyMessageUpdate',
						value: obj
					}));

					// Me
					Streamer.publish('talkStream:' + user.id + '-' + talkMessage.otherpartyId, JSON.stringify({
						type: 'meMessageUpdate',
						value: obj
					}));
				});
			});
		});
	});
}