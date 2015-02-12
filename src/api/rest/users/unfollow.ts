/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');

var authorize = require('../../auth');

var usersUnfollow = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.user_id != null) {
			var userId = req.body.user_id;
			UserFollowing.find(userId, user.id,(following: UserFollowing) => {
				if (following != null) {
					User.find(userId,(targetUser: User) => {
						following.destroy(() => {
							var streamObj: any = {};
							streamObj.type = 'unfollowedMe';
							streamObj.value = user.filt();
							Streamer.publish('userStream:' + targetUser.id, JSON.stringify(streamObj));

							res.apiRender(targetUser.filt());
						});
					});
				} else {
					res.apiError(400, 'This user is already not following :)');
				}
			});
		} else {
			res.apiError(400, 'user_id parameter is required :(');
		}
	});
}

module.exports = usersUnfollow;