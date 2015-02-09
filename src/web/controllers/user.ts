/// <reference path="../../../typings/bundle.d.ts" />

import User = require('../../models/user');
import Post = require('../../models/post');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	res.display(req, res, 'user', {
		user: req.rootUser,
		tags: req.rootUser.split(','),
		url: conf.publicConfig.url
	});
};
