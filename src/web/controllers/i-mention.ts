/// <reference path="../../../typings/bundle.d.ts" />

import Post = require('../../models/post');
import Timeline = require('../utils/timeline');
import conf = require('../../config');
import homeRender = require('./home');

export = render;

var render = (req: any, res: any): void => {
	homeRender(req, res, 'mention');
};
