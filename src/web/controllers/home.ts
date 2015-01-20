/// <reference path="../../../typings/bundle.d.ts" />

import Application = require('../../models/application');
import User = require('../../models/user');
import Post = require('../../models/post');

export = render;

var render = (req: any, res: any): void => {
	Post.getTimeline(req.me.id, 30, null, null, (posts: Post[]) => {
		Post.generateTimeline(posts, (timeline: Post[]) => {
			res.display(req, res, 'home', {
				timeline: timeline
			});
		});
	});
};
