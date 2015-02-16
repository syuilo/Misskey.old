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
			Post.getUserPostsCount(req.me.id,(count: number) => {
				callback(null, count);
			});
		},
		(callback: any) => {
			UserFollowing.getFollowingsCount(req.me.id,(count: number) => {
				callback(null, count);
			});
		},
		(callback: any) => {
			UserFollowing.getFollowersCount(req.me.id,(count: number) => {
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
					break;
				case 'followings':
					break;
				case 'followers':
					break;
			}
		}],
		(err: any, results: any) => {
			res.display(req, res, 'home', {
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
