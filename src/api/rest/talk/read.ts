/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import TalkMessage = require('../../../models/talk-message');
var authorize = require('../../auth');

module.exports = api;

function api(req: any, res: APIResponse) {
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

			if (talkMessage.otherpartyId != user.id) {
				res.apiError(400, 'Send Message opponent can only be to read.');
				return;
			}

			talkMessage.isReaded = true;
			talkMessage.update(() => {
				TalkMessage.buildResponseObject(talkMessage,(obj: any) => {
					// Send response
					res.apiRender(obj);
				});
			});
		});
	});
}