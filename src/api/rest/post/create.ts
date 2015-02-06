/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import Post = require('../../../models/post');

var authorize = require('../../auth');

var redis = require('redis');
var publisher = redis.createClient(6379, 'localhost');

var postCreate = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {
		var text = req.params.text != null ? req.params.text : '';
		var irtpi = req.params.in_reply_to_post_id != null ? req.params.in_reply_to_post_id : null;
		var image = req.params.image != null ? req.params.image : null;
		var isImageAttached = false;
		if (image != null) {
			console.log(image);
			isImageAttached = true;
		}
		console.log(app.id);
		console.log(irtpi);
		console.log(isImageAttached);
		console.log(text);
		console.log(user.id);
		Post.create(app.id, irtpi, null, isImageAttached, text, user.id, (post: Post) => {
			var streamObj: any = {};
			streamObj.type = 'post';
			streamObj.value = post;
			publisher.publish('misskey:userStream', JSON.stringify(streamObj));
			res.apiRender({ message: "ok" });
		});
	});
}
module.exports = postCreate;