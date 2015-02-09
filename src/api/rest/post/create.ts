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
	authorize(req, res,(user: User, app: Application) => {
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

		Post.create(app.id, irtpi, image, isImageAttached, text, user.id,(post: Post) => {
			generateStreamingObject(post,(obj: any) => {
				/* Publish post event */
				var streamObj: any = {};
				streamObj.type = 'post';
				streamObj.value = obj;

				// Me
				publisher.publish('misskey:userStream:' + user.id, JSON.stringify(streamObj));

				// Followers
				UserFollowing.findByFolloweeId(user.id,(userFollowings: UserFollowing[]) => {
					if (userFollowings != null) {
						userFollowings.forEach((userFollowing: UserFollowing) => {
							publisher.publish('misskey:userStream:' + userFollowing.followerId, JSON.stringify(streamObj));
						});
					}
				});

				// Sent response
				res.apiRender(obj);
			});
		});
	});
}

var generateStreamingObject = (post: Post, callback: (obj: any) => void): void => {
	delete post.image;
	var obj: any = post;
	obj.isReply = post.inReplyToPostId != 0 && post.inReplyToPostId != null;
	Application.find(post.appId,(app: Application) => {
		delete app.callbackUrl;
		delete app.consumerKey;
		delete app.icon;
		obj.app = app;
		User.find(post.userId,(user: User) => {
			delete user.header;
			delete user.icon;
			delete user.mailAddress;
			delete user.password;
			delete user.twitterAccessToken;
			delete user.twitterAccessTokenSecret;
			delete user.wallpaper;
			obj.user = user;
			if (obj.isReply) {
				Post.find(post.inReplyToPostId,(replyPost: Post) => {
					delete replyPost.image;
					obj.reply = replyPost;
					User.find(obj.reply.userId,(replyUser: User) => {
						delete replyUser.header;
						delete replyUser.icon;
						delete replyUser.mailAddress;
						delete replyUser.password;
						delete replyUser.twitterAccessToken;
						delete replyUser.twitterAccessTokenSecret;
						delete replyUser.wallpaper;
						obj.reply.user = replyUser;
						callback(obj);
					});
				});
			} else {
				callback(obj);
			}
		});
	});
};

module.exports = postCreate;