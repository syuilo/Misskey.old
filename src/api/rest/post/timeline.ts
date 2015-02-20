/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import Post = require('../../../models/post');
import Timeline = require('../../../web/utils/timeline');

var authorize = require('../../auth');

var postTimeline = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		var sinceId = req.query.since_id != null ? req.query.since_id: null;
		var maxId = req.query.max_id != null ? req.query.max_id : null;
		Post.getTimeline(req.me.id, 30, sinceId, maxId,(posts: Post[]) => {
				Timeline.selialyzeTimelineObject(posts, req,(filtedPosts: Post[]) => {
					res.apiRender(filtedPosts);
				});
		});
	});
}

module.exports = postTimeline;