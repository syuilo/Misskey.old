/// <reference path="../../../typings/bundle.d.ts" />

import jade = require('jade');
import Application = require('../../models/application');
import User = require('../../models/user');
import Post = require('../../models/post');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	Post.getTimeline(req.me.id, 30, null, null, (posts: Post[]) => {
		Post.generateTimeline(posts, (timeline: Post[]) => {
			res.display(req, res, 'home', {
				timeline: timeline,
				timelineHtml: jade.compileFile(__dirname + '/../views/templates/timeline.jade', {

				})({
					posts: timeline,
					url: conf.publicConfig.url
				}),
			});
		});
	});
};
