/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import jpeg = require('jpeg-js');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');
import Post = require('../../../models/post');

var authorize = require('../../auth');

var redis = require('redis');
var publisher = redis.createClient(6379, 'localhost');

var postCreate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		var text = req.body.text != null ? req.body.text : '';
		var irtpi = req.body.in_reply_to_post_id != null ? req.body.in_reply_to_post_id : null;
		var image: string = null;
		var isImageAttached = false;
		if (Object.keys(req.files).length === 1) {
			isImageAttached = true;
			var path = req.files.image.path;
			image = jpeg.encode(jpeg.decode(fs.readFileSync(path)), 50).data;
			fs.unlink(path);
		}

		Post.create(app.id, irtpi, image, isImageAttached, text, user.id, (post: Post) => {
			/* Publish post event */
			var streamObj: any = {};
			streamObj.type = 'post';
			streamObj.value = post;

			// Me
			publisher.publish('misskey:userStream:' + user.id, JSON.stringify(streamObj));

			// Followers
			UserFollowing.findByFolloweeId(user.id, (userFollowings: UserFollowing[]) => {
				if (userFollowings != null) {
					userFollowings.forEach((userFollowing: UserFollowing) => {
						publisher.publish('misskey:userStream:' + userFollowing.followerId, JSON.stringify(streamObj));
					});
				}
			});

			// Sent response
			res.apiRender({ message: "ok" });
		});
	});
}
module.exports = postCreate;