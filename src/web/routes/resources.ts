/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import express = require('express');
import gm = require('gm');
import compress = require('compression');
import less = require('less');
import User = require('../../models/user');
import WebTheme = require('../../models/webtheme');
import config = require('../../config');

export = router;

function compileLess(lessCss: string, styleUser: User, callback: (css: string) => void) {
	lessCss = lessCss.replace(/<%themeColor%>/g, styleUser != null ? styleUser.color : '#831c86');
	lessCss = lessCss.replace(/<%wallpaperUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/wallpaper/${styleUser.screenName}"` : '');
	lessCss = lessCss.replace(/<%headerImageUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/header/${styleUser.screenName}"` : '');
	lessCss = lessCss.replace(/<%headerBlurImageUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/header/${styleUser.screenName}?blur={\"radius\": 64, \"sigma\": 20}"` : '');
	less.render(lessCss, { compress: true },(err: any, output: any) => {
		if (err) throw err;
		callback(output.css);
	});
}

function readFileSendLess(req: any, res: any, resourcePath: string, styleUser: User) {
	fs.readFile(resourcePath, 'utf8',(err: NodeJS.ErrnoException, lessCss: string) => {
		if (err) throw err;
		compileLess(lessCss, styleUser,(css: string) => {
			res.header("Content-type", "text/css");
			res.send(css);
		});
	});
}

var router = (app: any): void => {
	/* Theme */
	app.get(/^\/resources\/styles\/theme\/([a-zA-Z0-9_-]+).*/,(req: any, res: any, next: () => void) => {
		if (req.query.user == null) {
			app.initSession(req, res,() => {
				if (req.login) {
					SendThemeStyle(req.me);
				} else {
					res.send('');
				}
			});
		} else {
			User.findByScreenName(req.query.user,(themeUser: User) => {
				if (themeUser != null) {
					SendThemeStyle(themeUser);
				} else {
					res.status(404).send('User not found.');
				}
			});
		}

		function SendThemeStyle(user: User) {
			var styleName = req.params[0];
			var themeId = user.webThemeId;
			if (themeId == null) {
				res.send('');
				return;
			}
			WebTheme.find(themeId,(theme: WebTheme) => {
				if (theme == null) {
					res.send('');
					return;
				}

				try {
					var themeObj = JSON.parse(theme.style);
					if (themeObj[styleName]) {
						compileLess(themeObj[styleName], user,(css: string) => {
							res.header("Content-type", "text/css");
							res.send(css);
						});
					} else {
						res.send('');
					}
				} catch (e) {
					res.status(500).send('Theme parse failed.');
				}
			});
		}
	});

	/* General */
	app.get(/^\/resources\/.*/,(req: any, res: any, next: () => void) => {
		if (req.path.indexOf('..') === -1) {
			if (req.path.match(/\.css$/)) {
				var resourcePath = path.resolve(__dirname + '/..' + req.path.replace(/\.css$/, '.less'));
				if (fs.existsSync(resourcePath)) {
					app.initSession(req, res,() => {
						if (req.query.user == null) {
							if (req.login) {
								readFileSendLess(req, res, resourcePath, req.me);
							} else {
								readFileSendLess(req, res, resourcePath, null);
							}
						} else {
							User.findByScreenName(req.query.user,(styleUser: User) => {
								if (styleUser != null) {
									readFileSendLess(req, res, resourcePath, styleUser);
								} else {
									readFileSendLess(req, res, resourcePath, null);
								}
							});
						}
					});
					return;
				}
			}
			if (req.url.indexOf('.less') === -1) {
				var resourcePath = path.resolve(__dirname + '/..' + req.path);
				res.sendFile(resourcePath);
			} else {
				next();
			}
		}
	});
};