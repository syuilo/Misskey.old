/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Post = require('../../models/post');
import User = require('../../models/user');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	async.series([
		(callback: any) => {
			Post.getBeforeTalk(req.rootPost.id,(posts: Post[]) => {
				async.map(posts,(post: any, next: any) => {
					User.find(post.userId,(user: User) => {
						post.user = user;
						next(null, user);
					});
				},(err: any, results: any[]) => {
						callback(null, results);
					});
			});
		}
	],(err: any, results: any) => {
			var post: any = req.rootPost;
			post.user = req.rootUser;
			res.display(req, res, 'post', {
				post: post,
				beforeTalks: results[0]
			});
		});
};
