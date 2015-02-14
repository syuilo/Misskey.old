/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import gm = require('gm');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');
import TalkMessage = require('../../../models/talk-message');

var authorize = require('../../auth');

var talkSay = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		var text = req.body.text != null ? req.body.text : '';

		if (req.body.otherparty_id == null) {
			res.apiError(400, 'otherparty_id parameter is required :(');
			return;
		}
		var otherpartyId = req.body.otherparty_id;

		UserFollowing.isFollowing(otherpartyId, user.id,(isFollowing: boolean) => {
			if (!isFollowing) {
				res.apiError(400, 'You are not follow from this user. To send a message, you need to have been followed from the other party.');
				return;
			}

			if (Object.keys(req.files).length === 1) {
				var path = req.files.image.path;
				var imageQuality = user.isPremium ? 100 : 70;
				gm(path)
					.compress('jpeg')
					.quality(imageQuality)
					.toBuffer('jpeg',(error: any, buffer: Buffer) => {
					if (error) throw error;
					fs.unlink(path);

					create(req, res, app.id, otherpartyId, buffer, true, text, user.id);
				});
			} else {
				create(req, res, app.id, otherpartyId, null, false, text, user.id);
			}
		});
	});
}

var create = (req: any, res: APIResponse, appId: number, otherpartyId: number, image: Buffer, isImageAttached: boolean, text: string, userId: number) => {
	TalkMessage.create(appId, userId, otherpartyId, text, isImageAttached, image,(talkMessage: TalkMessage) => {
		buildResponseObject(talkMessage,(obj: any) => {
			// Sent response
			res.apiRender(obj);

			// Other party (home)
			Streamer.publish('userStream:' + otherpartyId, {
				type: 'talkMessage',
				value: obj
			});

			// Other party
			Streamer.publish('talkStream:' + otherpartyId + '-' + userId, {
				type: 'otherpartyMessage',
				value: obj
			});

			// Me
			Streamer.publish('talkStream:' + userId + '-' + otherpartyId, {
				type: 'meMessage',
				value: obj
			});
		});
	});
};

var buildResponseObject = (talkMessage: TalkMessage, callback: (obj: any) => void): void => {
	delete talkMessage.image;
	var obj: any = talkMessage;
	Application.find(talkMessage.appId,(app: Application) => {
		delete app.callbackUrl;
		delete app.consumerKey;
		delete app.icon;
		obj.app = app;
		User.find(talkMessage.userId,(user: User) => {
			obj.user = user.filt();
			User.find(obj.toUserId,(otherparty: User) => {
				obj.otherparty = otherparty.filt();
				callback(obj);
			});
		});
	});
};

module.exports = talkSay;