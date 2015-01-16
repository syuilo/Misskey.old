/// <reference path="../../../../typings/bundle.d.ts" />


import express = require('express');
import async = require('async');
import Application = require('../../model/application');
import User = require('../../model/user');
import Post = require('../../model/post');

export = render;

var render = (req: any, res: any): void => {
	if (req.login) {
		Post.getTimeline(req.me.id, 30, null, null, (posts: Post[]) => {
			async.map(posts, (post: any, next) => {
				post.isReply = post.inReplyToPostId != null;
				User.find(post.userId, (user: User) => {
					post.user = user;
					Application.find(post.appId, (app: Application) => {
						post.app = app;
						if (post.isReply) {
							Post.find(post.inReplyToPostId, (replyPost: any) => {
								post.reply = replyPost;
								User.find(post.reply.userId, (replyUser: User) => {
									post.reply.user = replyUser;
									next(null, post);
								});
							});
						} else {
							next(null, post);
						}
					});
				})
			}, (err, results) => {
				res.display(req, res, 'home', {
					timeline: results
				});
			});
		});
	} else {
		res.display(req, res, 'entrance', {});
	}
};
