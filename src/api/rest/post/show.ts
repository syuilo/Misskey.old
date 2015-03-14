/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Application = require('../../../models/application');
import Post = require('../../../models/post');
import User = require('../../../models/user');

var authorize = require('../../auth');

var showPost = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		if (req.query.post_id == null) {
			res.apiError(400, 'post_id parameter is required :(');
			return;
		}
		Post.find(req.query.post_id, (post: Post) => {
			if (post == null) {
				res.apiError(404, 'Not found that post :(');
				return;
			}
			res.apiRender(post);
		});
	});
}

module.exports = showPost;
