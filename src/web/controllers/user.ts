/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import User = require('../../models/user');
import UserFollowing = require('../../models/user-following');
import Post = require('../../models/post');
import Timeline = require('../utils/timeline');
import conf = require('../../config');

export = render;

var render = (req: any, res: any, content: string = 'home'): void => {
	async.series([
		(callback: any) => {
			Post.getUserPostsCount(req.rootUser.id,(count: number) => {
				callback(null, count);
			});
		},
		(callback: any) => {
			UserFollowing.getFollowingsCount(req.rootUser.id,(count: number) => {
				callback(null, count);
			});
		},
		(callback: any) => {
			UserFollowing.getFollowersCount(req.rootUser.id,(count: number) => {
				callback(null, count);
			});
		},
		(callback: any) => {
			Post.findByUserId(req.rootUser.id, 30, null, null,(posts: Post[]) => {
				Timeline.generateHtml(posts,(timelineHtml: string) => {
					callback(null, timelineHtml);
				});
			});
		},
		(callback: any) => {
			switch (content) {
				case 'home':
					callback(null, null);
					break;
				case 'followings':
					callback(null, null);
					break;
				case 'followers':
					callback(null, null);
					break;
			}
		}],
		(err: any, results: any) => {
			res.display(req, res, 'user', {
				postsCount: results[0],
				followingsCount: results[1],
				followersCount: results[2],
				timelineHtml: results[3],
				user: req.rootUser,
				tags: req.rootUser.tag.split(','),
				url: conf.publicConfig.url,
			});
		});
};
