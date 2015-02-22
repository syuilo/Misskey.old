/// <reference path="../../../typings/bundle.d.ts" />

import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	res.display(req, res, 'new', {});
};
