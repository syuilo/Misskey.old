/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import webtheme = require('../../models/webtheme');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	res.display(req, res, 'dev-usertheme-new', {});
};
