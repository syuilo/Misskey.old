/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import jpeg = require('jpeg-js');
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
		var text = req.body.text != null ? req.body.text : '';
		var irtpi = req.body.in_reply_to_post_id != null ? req.body.in_reply_to_post_id : null;
		var image: string = null;
		var isImageAttached = false;
		if (Object.keys(req.files).length === 1) {
			isImageAttached = true;
			var path = req.files.image.path;
			image = jpeg.encode(fs.readFileSync(path), 50);
			fs.unlink(path);
		}

		Post.create(app.id, irtpi, image, isImageAttached, text, user.id, (post: Post) => {
			var streamObj: any = {};
			streamObj.type = 'post';
			streamObj.value = post;
			publisher.publish('misskey:userStream', JSON.stringify(streamObj));
			res.apiRender({ message: "ok" });
		});
	});
}
module.exports = postCreate;