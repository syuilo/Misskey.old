/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import express = require('express');
import gm = require('gm');
import compress = require('compression');
import less = require('less');
import User = require('../../models/user');
import config = require('../../config');

export = router;

function sentLess(req: any, res: any, resourcePath: string, styleUser: User) {
	fs.readFile(resourcePath, 'utf8',(err: NodeJS.ErrnoException, lessCss: string) => {
		if (err) throw err;
		lessCss = lessCss.replace(/<%themeColor%>/g, styleUser != null ? styleUser.color : '#831c86');
		lessCss = lessCss.replace(/<%wallpaperUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/wallpaper/${styleUser.screenName}"` : '');
		lessCss = lessCss.replace(/<%headerImageUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/header/${styleUser.screenName}"` : '');
		lessCss = lessCss.replace(/<%headerBlurImageUrl%>/g, styleUser != null ? `"${config.publicConfig.url}/img/header/${styleUser.screenName}?blur=64"` : '');
		less.render(lessCss, { compress: true },(err: any, output: any) => {
			if (err) throw err;
			res.header("Content-type", "text/css");
			res.send(output.css);
		});
	});
}

var router = (app: any): void => {
	/* Theme */
	app.get(/^\/resources\/theme\/.*/,(req: any, res: any, next: () => void) => {
		
	});

	/* General */
	app.get(/^\/resources\/.*/,(req: any, res: any, next: () => void) => {
		if (req.url.indexOf('..') === -1) {
			if (req.path.match(/\.css$/)) {
				var resourcePath = path.resolve(__dirname + '/..' + req.path.replace(/\.css$/, '.less'));
				if (fs.existsSync(resourcePath)) {
					app.initSession(req, res,() => {
						if (req.login) {
							if (req.query.user == null) {
								sentLess(req, res, resourcePath, req.me);
							} else {
								User.findByScreenName(req.query.user,(styleUser: User) => {
									if (styleUser != null) {
										sentLess(req, res, resourcePath, styleUser);
									} else {
										sentLess(req, res, resourcePath, null);
									}
								});
							}
						} else {
							sentLess(req, res, resourcePath, null);
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