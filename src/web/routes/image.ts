/// <reference path="../../../typings/bundle.d.ts" />

import express = require('express');
import User = require('../../models/user');
import Post = require('../../models/post');
import TalkMessage = require('../../models/talk-message');
import config = require('../../config');

export = router;

var router = (app: express.Express): void => {
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

	app.get('/img/talk-message/:id',(req: any, res: any) => {
		TalkMessage.find(req.params.id,(talkMessage: TalkMessage) => {
			if (talkMessage != null) {
				if (talkMessage.isImageAttached) {
					var img = talkMessage.image;
					res.set('Content-Type', 'image/jpeg');
					res.send(img);
				} else {
					res.status(404).send('Image not found.');
				}
			} else {
				res.status(404).send('Message not found.');
			}
		});
	});
};