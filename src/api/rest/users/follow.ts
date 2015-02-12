/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');

var authorize = require('../../auth');

var usersFollow = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.user_id != null) {
			var userId = req.body.user_id;
			UserFollowing.isFollowing(user.id, userId,(isFollowing: boolean) => {
				if (!isFollowing) {
					User.find(userId,(targetUser: User) => {
						if (targetUser != null) {
							UserFollowing.create(targetUser.id, user.id,(following: UserFollowing) => {
								var streamObj: any = {};
								streamObj.type = 'followedMe';
								streamObj.value = user.filt();
								Streamer.publish('userStream:' + targetUser.id, JSON.stringify(streamObj));

								res.apiRender(targetUser.filt());
							});
						} else {
							res.apiError(400, 'User not found...');
						}
					});
				} else {
					res.apiError(400, 'This user is already following :)');
				}
			});
		} else {
			res.apiError(400, 'user_id parameter is required :(');
		}
	});
}

module.exports = usersFollow;