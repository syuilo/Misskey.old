/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import Post = require('../../../models/post');

var authorize = require('../../auth');

var redis = require('redis');
var publisher = redis.createClient(6379, 'localhost');

var postCreate = (req: Express.Request, res: APIResponse) => {
	authorize(req, (user: User, app: Application) => {
		var text = req.param('text');
		var irtpi = req.param('in_reply_to_post_id');
		var image = req.param('image');
		console.log(image);
		Post.create(app.id, irtpi, null, false, text,user.id, (post: Post) => {
			var streamObj = {};
			streamObj.type = 'post';
			streamObj.value = post;
			publisher.publish('misskey:userStream', JSON.stringify(streamObj));
			res.apiRender({ message: "ok" });
		});
	});
}
module.exports = postCreate;