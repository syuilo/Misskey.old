/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import gm = require('gm');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');
import Post = require('../../../models/post');
import PostMention = require('../../../models/post-mention');

var authorize = require('../../auth');

var postCreate = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		var text = req.body.text != null ? req.body.text : '';
		var irtpi = req.body.in_reply_to_post_id != null ? req.body.in_reply_to_post_id : null;

		if (Object.keys(req.files).length === 1) {
			var path = req.files.image.path;
			var imageQuality = user.isPremium ? 100 : 70;
			gm(path)
				.compress('jpeg')
				.quality(imageQuality)
				.toBuffer('jpeg',(error: any, buffer: Buffer) => {
				if (error) throw error;
				fs.unlink(path);

				create(req, res, app.id, irtpi, buffer, true, text, user.id);
			});
		} else {
			create(req, res, app.id, irtpi, null, false, text, user.id);
		}
	});
}

var create = (req: any, res: APIResponse, appId: number, irtpi: number, image: Buffer, isImageAttached: boolean, text: string, userId: number) => {
	Post.create(appId, irtpi, image, isImageAttached, text, userId,(post: Post) => {
		buildResponseObject(post,(obj: any) => {
			// Sent response
			res.apiRender(obj);

			/* Publish post event */
			var streamObj: any = {};
			streamObj.type = 'post';
			streamObj.value = obj;

			// Me
			Streamer.publish('userStream:' + userId, JSON.stringify(streamObj));

			// Followers
			UserFollowing.findByFolloweeId(userId,(userFollowings: UserFollowing[]) => {
				if (userFollowings != null) {
					userFollowings.forEach((userFollowing: UserFollowing) => {
						Streamer.publish('userStream:' + userFollowing.followerId, JSON.stringify(streamObj));
					});
				}
			});

			// Mentions
			var mentions = post.text.match(/@[a-zA-Z0-9_]+/g);
			if (mentions != null) {
				mentions.forEach((mentionSn: string) => {
					mentionSn = mentionSn.replace('@', '');
					User.findByScreenName(mentionSn,(replyUser: User) => {
						if (replyUser != null) {
							PostMention.create(post.id, replyUser.id,(createdMention: PostMention) => {
								var streamMentionObj: any = {};
								streamMentionObj.type = 'reply';
								streamMentionObj.value = obj;
								Streamer.publish('userStream:' + replyUser.id, JSON.stringify(streamMentionObj));
							});
						}
					});
				});
			}
		});
	});
};

var buildResponseObject = (post: Post, callback: (obj: any) => void): void => {
	delete post.image;
	var obj: any = post;
	obj.isReply = post.inReplyToPostId != 0 && post.inReplyToPostId != null;
	Application.find(post.appId,(app: Application) => {
		delete app.callbackUrl;
		delete app.consumerKey;
		delete app.icon;
		obj.app = app;
		User.find(post.userId,(user: User) => {
			obj.user = user.filt();
			if (obj.isReply) {
				Post.find(post.inReplyToPostId,(replyPost: Post) => {
					delete replyPost.image;
					var replyObj: any = replyPost;
					replyObj.isReply = replyPost.inReplyToPostId != 0 && replyPost.inReplyToPostId != null;
					obj.reply = replyObj;
					User.find(obj.reply.userId,(replyUser: User) => {
						obj.reply.user = replyUser.filt();
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