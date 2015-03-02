/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');

import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	async.series([
		(callback: any) => {
            Application.findByScreenName(req.me.screenName,(apps: Application[]) => {
				callback(null, apps);
			});
		}],
		(err: any, results: any) => {
			res.display(req, res, 'dev', {
				apps: results[0],
			});
		});
};
