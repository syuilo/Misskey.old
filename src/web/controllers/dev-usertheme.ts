/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import webtheme = require('../../models/webtheme');
import fs = require('fs');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	async.series([
		(callback: any) => {
			webtheme.find(req.query.q, (apps: webtheme) => {
				callback(null, apps);
			});
		}],
		(err: any, results: any) => {
			res.display(req, res, 'dev-usertheme', {
				theme: results[0],
			});
		});
};
