/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import express = require('express');
import less = require('less');
import AccessToken = require('../../models/access-token');
import User = require('../../models/user');
import Post = require('../../models/post');
import doLogin = require('../controllers/login');
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

var router = (app: express.Express): void => {
	app.all('*', (req: any, res: any, next: () => void ) => {
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

		/* Jade  pretty setting */
		req.pretty = '  ';

		/* Renderer function */
		res.display = display;

		if (req.login) {
			var userId = req.session.userId;
			User.find(userId, (user: User) => {
				req.data.me = user;
				req.me = user;
				next();
			});
		} else {
			req.data.me = null;
			req.me = null;
			next();
		}
	});

	app.param('userSn', (req: any, res: any, next: () => void, sn: string) => {
		User.findByScreenName(sn, (user: User) => {
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
		var path = __dirname + '/statics' + req.url;
		fs.readFile(path, 'utf8', (err: NodeJS.ErrnoException, lessCss: string) => {
			if (err) throw err;
			lessCss = lessCss.replace(/<%themeColor%>/g, req.login ? req.me.color : '#831c86');
			less.render(lessCss, (err: any, css: string) => {
				if (err) throw err;
				res.header("Content-type", "text/css");
				res.send(css);
			});
		});
	});

	app.use(express.static(__dirname + '/statics'));

	app.get('/', (req: any, res: any, next: () => void) => {
		if (req.login) {
			require('../controllers/home')(req, res);
		} else {
			res.display(req, res, 'entrance', {});
		}
	});

	app.get('/config',(req: any, res: any, next: () => void) => {
		res.set('Content-Type', 'application/javascript');
		res.send('var conf = ' + JSON.stringify(config.publicConfig) + ';');
	});

	/* Images */

	app.get('/img/icon/:sn', (req: any, res: any) => {
		User.findByScreenName(req.params.sn, (user: User) => {
			if (user != null) {
				var img = user.icon;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('User not found.');
			}
		});
	});

	app.get('/img/post/:id', (req: any, res: any) => {
		Post.find(req.params.id, (post: Post) => {
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

	app.get('/login', (req: any, res: any) => {
		res.display(req, res, 'login', {});
	});

	app.post('/login', (req: any, res: any) => {
		doLogin(app, req.body.screen_name, req.body.password, (user: User, webAccessToken: AccessToken) => {
			req.session.userId = user.id;
			req.session.consumerKey = config.webClientConsumerKey;
			req.session.accessToken = webAccessToken.token;
			req.session.save(() => res.sendStatus(200));
		}, () => res.sendStatus(400));
	});

	app.get('/logout', (req: any, res: any) => {
		req.session.destroy((err: any) => {
			res.redirect('/');
		});
	});

	app.get('/:userSn', require('../controllers/user'));

	var display = (req: any, res: any, name: string, renderData: any) => {
		res.render(name, extend(req.data, renderData));
	};
};