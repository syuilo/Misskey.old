/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import express = require('express');
import less = require('less');
import AccessToken = require('../../models/access-token');
import User = require('../../models/user');
import Post = require('../../models/post');
import doLogin = require('../utils/login');
import config = require('../../config');

export = router;

var extend = (destination: any, source: any): Object => {
	for (var k in source) {
		if (source.hasOwnProperty(k)) {
			destination[k] = source[k];
		}
	}
	return destination;
};

function sentLess(req: any, res: any, resourcePath: string) {
	fs.readFile(resourcePath, 'utf8',(err: NodeJS.ErrnoException, lessCss: string) => {
		if (err) throw err;
		lessCss = lessCss.replace(/<%themeColor%>/g, req.login ? req.me.color : '#831c86');
		lessCss = lessCss.replace(/<%wallpaperUrl%>/g, req.login ? `"${config.publicConfig.url}/img/wallpaper/${req.me.screenName}"` : '');
		less.render(lessCss, { compress: true },(err: any, output: any) => {
			if (err) throw err;
			res.header("Content-type", "text/css");
			res.send(output.css);
		});
	});
}

var router = (app: express.Express): void => {
	function initSession(req: any, res: any, callback: () => void) {
		res.set({
			'Access-Control-Allow-Origin': config.publicConfig.url,
			'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
			'Access-Control-Allow-Credentials': true,
			'X-Frame-Options': 'DENY'
		});

		/* Is logged */
		req.login = (req.session != null && req.session.userId != null);

		/* Render datas */
		req.data = {};
		req.data.config = config;
		req.data.url = config.publicConfig.url;
		req.data.apiUrl = config.publicConfig.apiUrl;
		req.data.login = req.login;

		/* Renderer function */
		res.display = display;

		if (req.login) {
			var userId = req.session.userId;
			User.find(userId,(user: User) => {
				req.data.me = user;
				req.me = user;
				callback();
			});
		} else {
			req.data.me = null;
			req.me = null;
			callback();
		}
	}

	app.get(/^\/resources\/.*/,(req: any, res: any, next: () => void) => {
		if (req.url.indexOf('..') === -1) {
			if (req.url.match(/\.css$/)) {
				var resourcePath = path.resolve(__dirname + '/..' + req.url.replace(/\.css$/, '.less'));
				if (fs.existsSync(resourcePath)) {
					initSession(req, res,() => {
						sentLess(req, res, resourcePath);
					});
					return;
				}
			}
			if (req.url.indexOf('.less') === -1) {
				var resourcePath = path.resolve(__dirname + '/..' + req.url);
				res.sendFile(resourcePath);
			} else {
				next();
			}
		}
	});

	app.all('*',(req: any, res: any, next: () => void) => {
		initSession(req, res,() => {
			next();
		});
	});

	app.param('userSn',(req: any, res: any, next: () => void, sn: string) => {
		User.findByScreenName(sn,(user: User) => {
			if (user != null) {
				req.rootUser = user;
				next();
			} else {
				res.display(req, res, 'user-notFound', {
				});
			}
		});
	});

	app.get('*.less',(req: any, res: any) => {
		if (req.url.indexOf('..') === -1) {
			var resourcePath = path.resolve(__dirname + '/..' + req.url);
			sentLess(req, res, resourcePath);
		}
	});

	app.get('/',(req: any, res: any, next: () => void) => {
		if (req.login) {
			require('../controllers/home')(req, res);
		} else {
			res.display(req, res, 'entrance', {});
		}
	});

	app.get('/i/mention',(req: any, res: any, next: () => void) => {
		require('../controllers/i-mention')(req, res);
	});
	app.get('/i/mentions',(req: any, res: any, next: () => void) => {
		require('../controllers/i-mention')(req, res);
	});

	app.get('/i/setting',(req: any, res: any, next: () => void) => {
		require('../controllers/i-setting')(req, res);
	});
	app.get('/i/settings',(req: any, res: any, next: () => void) => {
		require('../controllers/i-setting')(req, res);
	});

	app.get('/config',(req: any, res: any, next: () => void) => {
		res.set('Content-Type', 'application/javascript');
		res.send('var conf = ' + JSON.stringify(config.publicConfig) + ';');
	});

	/* Images */

	app.get('/img/icon/:sn',(req: any, res: any) => {
		User.findByScreenName(req.params.sn,(user: User) => {
			if (user != null) {
				var img = user.icon;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('User not found.');
			}
		});
	});

	app.get('/img/header/:sn',(req: any, res: any) => {
		User.findByScreenName(req.params.sn,(user: User) => {
			if (user != null) {
				var img = user.header;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('User not found.');
			}
		});
	});

	app.get('/img/wallpaper/:sn',(req: any, res: any) => {
		User.findByScreenName(req.params.sn,(user: User) => {
			if (user != null) {
				var img = user.wallpaper;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('User not found.');
			}
		});
	});

	app.get('/img/post/:id',(req: any, res: any) => {
		Post.find(req.params.id,(post: Post) => {
			if (post != null) {
				if (post.isImageAttached) {
					var img = post.image;
					res.set('Content-Type', 'image/jpeg');
					res.send(img);
				} else {
					res.status(404).send('Image not found.');
				}
			} else {
				res.status(404).send('Post not found.');
			}
		});
	});

	/* Actions */

	app.get('/login',(req: any, res: any) => {
		res.display(req, res, 'login', {});
	});

	app.post('/login',(req: any, res: any) => {
		doLogin(app, req.body.screen_name, req.body.password,(user: User, webAccessToken: AccessToken) => {
			req.session.userId = user.id;
			req.session.consumerKey = config.webClientConsumerKey;
			req.session.accessToken = webAccessToken.token;
			req.session.save(() => res.sendStatus(200));
		},() => res.sendStatus(400));
	});

	app.get('/logout',(req: any, res: any) => {
		req.session.destroy((err: any) => {
			res.redirect('/');
		});
	});

	app.get('/:userSn', require('../controllers/user'));

	var display = (req: any, res: any, name: string, renderData: any) => {
		res.render(name, extend(req.data, renderData));
	};
};