/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import WebTheme = require('../../models/webtheme');
import conf = require('../../config');

export = render;

function render(req: any, res: any): void {
	async.series([
		(callback: any) => {
			Application.findByUserId(req.me.id, (apps: Application[]) => {
				callback(null, apps);
			});
		},
		(callback: any) => {
			WebTheme.findByUserId(req.me.id, (themes: WebTheme[]) => {
				callback(null, themes);
			});
		}],
		(err: any, results: any) => {
			res.display(req, res, 'dev', {
				apps: results[0],
				themes: results[1],
			});
		});
};
