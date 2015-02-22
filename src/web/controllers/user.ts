/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import marked = require('marked');
import User = require('../../models/user');
import UserFollowing = require('../../models/user-following');
import Post = require('../../models/post');
import Timeline = require('../utils/timeline');
import conf = require('../../config');

marked.setOptions({
	gfm: true,
	breaks: true,
	sanitize: true
});

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
				Timeline.generateHtml(posts, req,(timelineHtml: string) => {
					callback(null, timelineHtml);
				});
			});
		},
		(callback: any) => {
			if (req.login) {
				UserFollowing.isFollowing(req.me.id, req.rootUser.id,(isFollowing: boolean) => {
					callback(null, isFollowing);
				});
			} else {
				callback(null, null);
			}
		},
		(callback: any) => {
			if (req.login) {
				UserFollowing.isFollowing(req.rootUser.id, req.me.id,(isFollowMe: boolean) => {
					callback(null, isFollowMe);
				});
			} else {
				callback(null, null);
			}
		},
		(callback: any) => {
			switch (content) {
				case 'home':
					if (req.rootUser.bio != null) {
						callback(null, marked(req.rootUser.bio));
					} else {
						callback(null, null);
					}
					break;
				case 'followings':
					UserFollowing.getFollowings(req.rootUser.id, 50,(userFollowings: UserFollowing[]) => {
						if (userFollowings != null) {
							async.map(userFollowings,(userFollowing: UserFollowing, next: any) => {
								User.find(userFollowing.followeeId,(user: User) => {
									next(null, user);
								});
							},(err: any, results: User[]) => {
									callback(null, results);
								});
						} else {
							callback(null, null);
						}
					});
					break;
				case 'followers':
					UserFollowing.getFollowers(req.rootUser.id, 50,(userFollowings: UserFollowing[]) => {
						if (userFollowings != null) {
							async.map(userFollowings,(userFollowing: UserFollowing, next: any) => {
								User.find(userFollowing.followerId,(user: User) => {
									next(null, user);
								});
							},(err: any, results: User[]) => {
									callback(null, results);
								});
						} else {
							callback(null, null);
						}
					});
					break;
			}
		}],
		(err: any, results: any) => {
			res.display(req, res, 'user', {
				postsCount: results[0],
				followingsCount: results[1],
				followersCount: results[2],
				timelineHtml: results[3],
				isFollowing: results[4],
				isFollowMe: results[5],
				content: results[6],
				user: req.rootUser,
				tags: req.rootUser.tag != null ? req.rootUser.tag.split(',') : null,
				url: conf.publicConfig.url,
				page: content
			});
		});
};
