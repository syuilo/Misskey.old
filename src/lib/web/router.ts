/// <reference path="../../../typings/bundle.d.ts" />

import express = require('express');
import User = require('../model/user');
import doLogin = require('./models/login');

export = router;

var extend = (destination: any, source: any): Object => {
	for (var k in source) {
		if (source.hasOwnProperty(k)) {
			destination[k] = source[k];
		}
	}
	return destination;
}

var router = (app: express.Express): void => {
	
	app.all('*', (req: express.Request, res: express.Response, next: () => void ) => {
		app.disable('x-powered-by');
		res.set({
			'Access-Control-Allow-Origin': 'https://misskey.xyz',
			'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
			'Access-Control-Allow-Credentials': true,
			'X-Frame-Options': 'DENY'
		});

		req.login = (req.session != null && req.session.userId != null);

		req.data = {};
		req.data.url = config.publicConfig.url;
		req.data.apiUrl = config.publicConfig.apiUrl;
		req.data.login = login;

		req.pretty = '  ';
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

	app.param('userSn', (req: express.Request, res: express.Response, next: () => void, sn: string) => {
		User.findByScreenName(sn, (user: User) => {
			if (user != null) {
				req.rootUser = user;
				next();
			} else {
				display(req, res, 'user-notFound', {
				});
			}
		});
	});

	app.get('/', (req: express.Request, res: express.Response) => {
		if (req.login) {
			display(req, res, 'home', {});
		} else {
			display(req, res, 'entrance', {});
		}
	});

	app.get('/login', function (req: express.Request, res: express.Response) {
		display(req, res, 'login', {});
	});

	app.post('/login', function (req: express.Request, res: express.Response) {
		doLogin(app, req.body.screen_name, req.body.password, (user: User) => {
			req.session.userId = user.id;
			res.write(200);
			res.end();
		}, () => {
			res.write(400);
			res.end();
		});
	});

	app.get('/logout', function (req: express.Request, res: express.Response) {
		req.session.destroy(function (err) {
			res.redirect('/');
		})
	});

	app.get('/:userSn', require('./models/user'));

	function display(req: express.Request, res: express.Response, name: string, renderData: any) {
		/* Mixin */
		res.render(name, extend(req.data, renderData));
	}
};