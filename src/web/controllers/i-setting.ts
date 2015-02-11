/// <reference path="../../../typings/bundle.d.ts" />

import Post = require('../../models/post');
import Timeline = require('../utils/timeline');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	res.display(req, res, 'i-setting', {
		me: req.me
	});
};
