/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import fs = require('fs');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	async.series([
		(callback: any) => {
			Application.find(req.query.q, (app: Application) => {
				callback(null, app);
			});
		}],
		(err: any, results: any) => {
			res.display(req, res, 'dev-myapp', {
				app: results[0],
			});
		});
};
