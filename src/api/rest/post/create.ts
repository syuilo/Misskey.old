/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import gm = require('gm');
import async = require('async');
import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');
import Post = require('../../../models/post');
import PostMention = require('../../../models/post-mention');

var authorize = require('../../auth');

var postCreate = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		var text = req.body.text != null ? req.body.text : '';
		var inReplyToPostId = req.body.in_reply_to_post_id != null ? req.body.in_reply_to_post_id : null;

		if (Object.keys(req.files).length === 1) {
			var path = req.files.image.path;
			var imageQuality = user.isPremium ? 90 : 70;
			gm(path)
				.compress('jpeg')
				.quality(imageQuality)
				.toBuffer('jpeg',(error: any, buffer: Buffer) => {
				if (error) throw error;
				fs.unlink(path);

				create(req, res, app.id, inReplyToPostId, buffer, true, text, user.id);
			});
		} else {
			create(req, res, app.id, inReplyToPostId, null, false, text, user.id);
		}
	});
}

function create(req: any, res: APIResponse, appId: number, irtpi: number, image: Buffer, isImageAttached: boolean, text: string, userId: number) {
	Post.create(appId, irtpi, image, isImageAttached, text, userId, null,(post: Post) => {
		Post.buildResponseObject(post,(obj: any) => {
			// More talk
			if (obj.reply != null) {
				if (obj.reply.isReply) {
					getMoreTalk(obj.reply,(talk: any[]) => {
						obj.moreTalk = talk;
						send(obj);
					});
				} else {
					send(obj);
				}
			} else {
				send(obj);
			}
		});
	});

	function send(obj: any) {
		// Sent response
		res.apiRender(obj);

		/* Publish post event */
		var streamObj = JSON.stringify({
			type: 'post',
			value: obj
		});
			
		// Me
		Streamer.publish('userStream:' + userId, streamObj);

		// Followers
		UserFollowing.findByFolloweeId(userId,(userFollowings: UserFollowing[]) => {
			if (userFollowings != null) {
				userFollowings.forEach((userFollowing: UserFollowing) => {
					Streamer.publish('userStream:' + userFollowing.followerId, streamObj);
				});
			}
		});

		// Mentions
		var mentions = obj.text.match(/@[a-zA-Z0-9_]+/g);
		if (mentions != null) {
			mentions.forEach((mentionSn: string) => {
				mentionSn = mentionSn.replace('@', '');
				User.findByScreenName(mentionSn,(replyUser: User) => {
					if (replyUser != null) {
						PostMention.create(obj.id, replyUser.id,(createdMention: PostMention) => {
							var streamMentionObj = JSON.stringify({
								type: 'reply',
								value: obj
							});
							Streamer.publish('userStream:' + replyUser.id, streamMentionObj);
						});
					}
				});
			});
		}
	}
}

function getMoreTalk(post: Post, callback: (talk: any[]) => void) {
	Post.getBeforeTalk(post.inReplyToPostId,(moreTalk: Post[]) => {
		async.map(moreTalk,(talkPost: any, mapNext: any) => {
			talkPost.isReply = talkPost.inReplyToPostId != 0 && talkPost.inReplyToPostId != null;
			User.find(talkPost.userId,(talkPostUser: User) => {
				talkPost.user = talkPostUser;
				mapNext(null, talkPost);
			});
		},(err: any, moreTalkPosts: any[]) => {
				callback(moreTalkPosts);
			});
	});
}

module.exports = postCreate;