/// <reference path="../../../../typings/bundle.d.ts" />

import Post = require('../../../models/post');
import Timeline = require('../../utils/timeline');
import conf = require('../../../config');

export = render;

var render = (req: any, res: any): void => {
	Post.getMentions(req.me.id, 30, null, null,(posts: Post[]) => {
		Timeline.generateHtml(posts,(timelineHtml: string) => {
			res.display(req, res, 'home', {
				timelineHtml: timelineHtml
			});
		});
	});
};
