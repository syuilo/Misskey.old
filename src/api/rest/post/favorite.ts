/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import Post = require('../../../models/post');
import PostFavorite = require('../../../models/post-favorite');
import Notice = require('../../../models/notice');
import config = require('../../../config');

var authorize = require('../../auth');

var postFavorite = (req: any, res: APIResponse) => {
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

			if (targetPost.repostFromPostId == null) {
				favoriteStep(req, res, app, user, targetPost);
			} else { // ふぁぼろうとしたPostがRPだった場合、本来のPostをふぁぼるようにする(RPをふぁぼらないようにする)
				Post.find(targetPost.repostFromPostId,(trueTargetPost: Post) => {
					favoriteStep(req, res, app, user, trueTargetPost);
				});
			}
		});
	});
}

function favoriteStep(req: any, res: APIResponse, app: Application, user: User, targetPost: Post) {
	PostFavorite.isFavorited(targetPost.id, user.id,(isFavorited: boolean) => {
		if (isFavorited) {
			res.apiError(400, 'This post is already favorited :)');
			return;
		}

		PostFavorite.create(targetPost.id, user.id,(favorite: PostFavorite) => {
			targetPost.favoritesCount++;
			targetPost.update(() => { });
			Post.buildResponseObject(targetPost,(obj: any) => {
				res.apiRender(obj);
			});

			var content: any = {};
			content.type = 'favorite';
			content.value = {};
			content.value.post = targetPost;
			content.value.user = user.filt();
			Notice.create(config.webClientId, JSON.stringify(content), targetPost.userId,(notice: Notice) => {
				Streamer.publish('userStream:' + targetPost.userId, JSON.stringify({
					type: 'notice',
					value: notice
				}));
			});
		});
	});
}

module.exports = postFavorite;