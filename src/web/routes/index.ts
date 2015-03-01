/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import express = require('express');
import AccessToken = require('../../models/access-token');
import User = require('../../models/user');
import Post = require('../../models/post');
import doLogin = require('../utils/login');
import config = require('../../config');
import imageRouter = require('./image');

export = router;

var router = (app: express.Express): void => {
	app.param('userSn',(req: any, res: any, next: () => void, sn: string) => {
		User.findByScreenName(sn,(user: User) => {
			if (user != null) {
				req.rootUser = user;
				req.data.rootUser = user;
				next();
			} else {
				res.status(404);
				res.display(req, res, 'user-notFound', {});
			}
		});
	});

	app.get('/',(req: any, res: any, next: () => void) => {
		if (req.login) {
			require('../controllers/home')(req, res);
		} else {
			res.display(req, res, 'entrance', {});
		}
	});

	app.get('/new',(req: any, res: any, next: () => void) => {
		require('../controllers/new')(req, res);
	});

	app.get('/i/mention',(req: any, res: any, next: () => void) => {
		require('../controllers/i-mention')(req, res);
	});
	app.get('/i/mentions',(req: any, res: any, next: () => void) => {
		require('../controllers/i-mention')(req, res);
	});

	app.get('/i/talk',(req: any, res: any, next: () => void) => {
		require('../controllers/i-talks')(req, res);
	});
	app.get('/i/talks',(req: any, res: any, next: () => void) => {
		require('../controllers/i-talks')(req, res);
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

	/* Actions */
	app.get('/login',(req: any, res: any) => {
		res.display(req, res, 'login', {});
	});

	app.post('/login',(req: any, res: any) => {
		doLogin(req, req.body.screen_name, req.body.password,(user: User, webAccessToken: AccessToken) => {
			res.sendStatus(200);
		},() => res.sendStatus(400));
	});

	app.get('/logout',(req: any, res: any) => {
		req.session.destroy((err: any) => {
			res.redirect('/');
		});
	});

	app.get('/:userSn',(req: any, res: any, next: () => void) => {
		require('../controllers/user')(req, res, 'home');
	});
	app.get('/:userSn/followings',(req: any, res: any, next: () => void) => {
		require('../controllers/user')(req, res, 'followings');
	});
	app.get('/:userSn/followers',(req: any, res: any, next: () => void) => {
		require('../controllers/user')(req, res, 'followers');
	});
	app.get('/:userSn/talk', require('../controllers/user-talk'));

	/* Image */
	imageRouter(app);
};