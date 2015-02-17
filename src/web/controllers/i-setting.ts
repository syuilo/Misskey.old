/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import User = require('../../models/user');
import WebTheme = require('../../models/webtheme');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	WebTheme.getThemes((themes: WebTheme[]) => {
		async.map(themes,(themes: any, next: any) => {
			User.find(themes.userId,(user: User) => {
				themes.user = user;
				next(null, themes);
			});
		},(err: any, results: any[]) => {
				res.display(req, res, 'i-setting', {
					me: req.me,
					webthemes: results
				});
			});
	});
};
