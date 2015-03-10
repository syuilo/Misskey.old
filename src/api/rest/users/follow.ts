/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');
import Notice = require('../../../models/notice');
import config = require('../../../config');

var authorize = require('../../auth');

var usersFollow = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.user_id == null) {
			res.apiError(400, 'user_id parameter is required :(');
			return;
		}
		var userId = req.body.user_id;

		UserFollowing.isFollowing(user.id, userId,(isFollowing: boolean) => {
			if (isFollowing) {
				res.apiError(400, 'This user is already following :)');
				return;
			}

			User.find(userId,(targetUser: User) => {
				if (targetUser == null) {
					res.apiError(404, 'User not found...');
					return;
				}

				UserFollowing.create(targetUser.id, user.id,(following: UserFollowing) => {
					var streamObj: any = {};
					streamObj.type = 'followedMe';
					streamObj.value = user.filt();
					Streamer.publish('userStream:' + targetUser.id, JSON.stringify(streamObj));

					res.apiRender(targetUser.filt());

					Notice.create(config.webClientId, user.name + '(@' + user.screenName + ') さんがあなたをフォローしました', targetUser.id, (notice: Notice) => {
						Streamer.publish('userStream:' + targetUser.id, JSON.stringify({
							type: 'notice',
							value: notice
						}));
					});
				});
			});
		});
	});
}

module.exports = usersFollow;