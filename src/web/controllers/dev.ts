/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');

import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	async.series([
		(callback: any) => {
			if (req.login) {
				Application.findByUserId(req.me.id, (apps: Application[]) => {
					callback(null, apps);
				});
			} else {
				callback(null, []);
			}
		}],
		(err: any, results: any) => {
			res.display(req, res, 'dev', {
				apps: results[0],
			});
		});
};
