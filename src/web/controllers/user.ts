/// <reference path="../../../typings/bundle.d.ts" />

import User = require('../../models/user');
import Post = require('../../models/post');
import Timeline = require('../utils/timeline');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	Post.findByUserId(req.rootUser.id, 30, null, null,(posts: Post[]) => {
		Timeline.generateHtml(posts,(timelineHtml: string) => {
			res.display(req, res, 'user', {
				user: req.rootUser,
				tags: req.rootUser.tag.split(','),
				url: conf.publicConfig.url,
				timelineHtml: timelineHtml
			});
		});
	});
};
