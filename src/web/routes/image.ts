/// <reference path="../../../typings/bundle.d.ts" />

import express = require('express');
import gm = require('gm');
import User = require('../../models/user');
import Post = require('../../models/post');
import TalkMessage = require('../../models/talk-message');
import config = require('../../config');

export = router;

var router = (app: express.Express): void => {
	app.get('/img/icon/:idOrSn',(req: any, res: any) => {
		if (req.params.idOrSn.match(/^[0-9]+$/)) {
			User.find(Number(req.params.idOrSn),(user: User) => {
				display(user);
			});
		} else {
			User.findByScreenName(req.params.idOrSn,(user: User) => {
				display(user);
			});
		}

		var display = (user: User) => {
			if (user != null) {
				var img = user.icon;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	app.get('/img/header/:idOrSn',(req: any, res: any) => {
		if (req.params.idOrSn.match(/^[0-9]+$/)) {
			User.find(Number(req.params.idOrSn),(user: User) => {
				display(user);
			});
		} else {
			User.findByScreenName(req.params.idOrSn,(user: User) => {
				display(user);
			});
		}

		var display = (user: User) => {
			if (user != null) {
				if (req.query.blur == null) {
					var img = user.header;
					res.set('Content-Type', 'image/jpeg');
					res.send(img);
				} else {
					gm(user.header)
						.blur(req.query.blur)
						.toBuffer('jpeg',(error: any, buffer: Buffer) => {
						if (error) throw error;
						res.set('Content-Type', 'image/jpeg');
						res.send(buffer);
					});
				}
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	app.get('/img/wallpaper/:idOrSn',(req: any, res: any) => {
		if (req.params.idOrSn.match(/^[0-9]+$/)) {
			User.find(Number(req.params.idOrSn),(user: User) => {
				display(user);
			});
		} else {
			User.findByScreenName(req.params.idOrSn,(user: User) => {
				display(user);
			});
		}

		var display = (user: User) => {
			if (user != null) {
				var img = user.wallpaper;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('User not found.');
			}
		};
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