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
		var image: string = null;
		var isImageAttached = false;
		if (Object.keys(req.files).length === 1) {
			isImageAttached = true;
			var path = req.files.image.path;
			gm(path)
				.compress('jpeg')
				.quality(70)
				.toBuffer('jpeg',(error: any, buffer: Buffer) => {
				if (error) throw error;
				image = buffer.toString('utf8');
				fs.unlink(path);
				create();
			});
		} else {
			create();
		}

		var create = () => {
			Post.create(app.id, irtpi, image, isImageAttached, text, user.id,(post: Post) => {
				generateStreamingObject(post,(obj: any) => {
					/* Publish post event */
					var streamObj: any = {};
					streamObj.type = 'post';
					streamObj.value = obj;

					// Me
					Streamer.publish('userStream:' + user.id, JSON.stringify(streamObj));

					// Followers
					UserFollowing.findByFolloweeId(user.id,(userFollowings: UserFollowing[]) => {
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

					// Sent response
					res.apiRender(obj);
				});
			});
		};
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
					var replyObj: any = replyPost;
					replyObj.isReply = replyPost.inReplyToPostId != 0 && replyPost.inReplyToPostId != null;
					obj.reply = replyObj;
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