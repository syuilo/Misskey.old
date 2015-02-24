/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import TalkMessage = require('../../../models/talk-message');
var authorize = require('../../auth');

module.exports = talkDelete;

function talkDelete(req: any, res: APIResponse) {
	authorize(req, res,(user: User, app: Application) => {
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

			talkMessage.isDeleted = true;
			talkMessage.update(() => {
				TalkMessage.buildResponseObject(talkMessage,(obj: any) => {
					// Sent response
					res.apiRender(obj);

					// Other party
					Streamer.publish('talkStream:' + talkMessage.otherpartyId + '-' + user.id, JSON.stringify({
						type: 'otherpartyMessageDelete',
						value: talkMessage.id
					}));

					// Me
					Streamer.publish('talkStream:' + user.id + '-' + talkMessage.otherpartyId, JSON.stringify({
						type: 'meMessageDelete',
						value: talkMessage.id
					}));
				});
			});
		});
	});
}