/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserFollowing = require('../../../models/user-following');
import Post = require('../../../models/post');

var authorize = require('../../auth');

var postRepost = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (req.body.post_id == null) {
			res.apiError(400, 'post_id parameter is required :(');
			return;
		}
		var postId = req.body.post_id;

		Post.find(postId,(targetPost: Post) => {
			if (targetPost == null) {
				res.apiError(404, 'Post not found...');
				return;
			}

			if (targetPost.userId == user.id) {
				res.apiError(400, 'This post is your post!!!');
				return;
			}

			if (targetPost.repostFromPostId == null) {
				repostStep(req, res, app, user, targetPost);
			} else { // RP‚µ‚æ‚¤‚Æ‚µ‚½Post‚ªRP‚¾‚Á‚½ê‡A–{—ˆ‚ÌPost‚ðRP‚·‚é‚æ‚¤‚É‚·‚é(RP‚ðRP‚µ‚È‚¢‚æ‚¤‚É‚·‚é)
				Post.find(targetPost.repostFromPostId,(trueTargetPost: Post) => {
					repostStep(req, res, app, user, trueTargetPost);
				});
			}
		});
	});
}

function repostStep(req: any, res: APIResponse, app: Application, user: User, targetPost: Post) {
	Post.isReposted(targetPost.id, user.id,(isReposted: boolean) => {
		if (isReposted) {
			res.apiError(400, 'This post is already reposted :)');
			return;
		}

		User.find(targetPost.userId,(targetPostUser: User) => {
			Post.create(app.id, null, null, 'RP @' + targetPostUser.screenName + ' ' + targetPost.text, user.id, targetPost.id,(post: Post) => {
				targetPost.repostsCount++;
				targetPost.update(() => { });
				Post.buildResponseObject(targetPost,(targetPostObj: any) => {
					targetPostObj.isRepostToPost = true;
					targetPostObj.repostedByUser = user.filt();
					// Sent response
					res.apiRender(targetPostObj);

					/* Publish post event */
					var streamObj = JSON.stringify({
						type: 'repost',
						value: targetPostObj
					});
			
					// Me
					Streamer.publish('userStream:' + user.id, streamObj);

					// Followers
					UserFollowing.findByFolloweeId(user.id,(userFollowings: UserFollowing[]) => {
						if (userFollowings != null) {
							userFollowings.forEach((userFollowing: UserFollowing) => {
								Streamer.publish('userStream:' + userFollowing.followerId, streamObj);
							});
						}
					});
				});
			});
		});
	});
}

module.exports = postRepost;