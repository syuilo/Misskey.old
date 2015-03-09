/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	res.display(req, res, 'dev-myapp-new', {});
};
