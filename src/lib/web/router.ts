/// <reference path="../../../typings/bundle.d.ts" />

import express = require('express');
import User = require('../model/user');
import Post = require('../model/post');
import doLogin = require('./models/login');

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

	var config = app.get('config');

	/* General */
	
	app.all('*', (req: any, res: any, next: () => void ) => {
		/* Response header setting */
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

	app.get('/', require('./models/root'));

	/* Images */

	app.get('/img/icon/:sn', (req: any, res: any) => {
		User.findByScreenName(req.params.sn, (user: User) => {
			if (user != null) {
				var img = user.icon;
				res.send(img, { 'Content-Type': 'image/jpeg' }, 200);
			} else {
				res.sendStatus(404);
			}
		});
	});

	app.get('/img/post/:id', (req: any, res: any) => {
		Post.find(req.params.id, (post: Post) => {
			if (post != null) {
				if (post.isImageAttached) {
					var img = post.image;
					res.send(img, { 'Content-Type': 'image/jpeg' }, 200);
				} else {
					res.sendStatus(404);
				}
			} else {
				res.sendStatus(404);
			}
		});
	});

	/* Actions */

	app.get('/login', (req: any, res: any) => {
		res.display(req, res, 'login', {});
	});

	app.post('/login', (req: any, res: any) => {
		doLogin(app, req.body.screen_name, req.body.password, (user: User) => {
			req.session.userId = user.id;
			req.session.save(() => {
				res.sendStatus(200);
			});
		}, () => {
			res.sendStatus(400);
		});
	});

	app.get('/logout', (req: any, res: any) => {
		req.session.destroy((err: any) => {
			res.redirect('/');
		});
	});

	/* Pages */

	//app.get('/:userSn', require('./models/user'));

	var display = (req: any, res: any, name: string, renderData: any) => {
		/* Mixin */
		res.render(name, extend(req.data, renderData));
	};
};