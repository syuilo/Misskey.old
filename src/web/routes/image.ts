/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import express = require('express');
import gm = require('gm');
import User = require('../../models/user');
import Post = require('../../models/post');
import TalkMessage = require('../../models/talk-message');
import WebTheme = require('../../models/webtheme');
import config = require('../../config');

export = router;

var router = (app: express.Express): void => {
	/* User icon */
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
				var imageBuffer = user.icon != null ? user.icon : fs.readFileSync(path.resolve(__dirname + '/../resources/images/icon_default.jpg'));
				res.set('Content-Type', 'image/jpeg');
				res.send(imageBuffer);
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	/* User header */
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
				var imageBuffer = user.header != null ? user.header : fs.readFileSync(path.resolve(__dirname + '/../resources/images/header_default.jpg'));
				if (req.query.blur == null) {
					res.set('Content-Type', 'image/jpeg');
					res.send(imageBuffer);
				} else {
					gm(imageBuffer)
						.blur(req.query.blur, 20)
						.compress('jpeg')
						.quality(80)
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

	/* User wallpaper */
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
				var imageBuffer = user.wallpaper != null ? user.wallpaper : fs.readFileSync(path.resolve(__dirname + '/../resources/images/wallpaper_default.jpg'));
				res.set('Content-Type', 'image/jpeg');
				res.send(imageBuffer);
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	/* Post */
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

	/* Talk message */
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

	/* Webtheme thumbnail */
	app.get('/img/webtheme_thumbnail/:id',(req: any, res: any) => {
		WebTheme.find(req.params.id,(webtheme: WebTheme) => {
			if (webtheme != null) {
				var img = webtheme.thumbnail;
				res.set('Content-Type', 'image/jpeg');
				res.send(img);
			} else {
				res.status(404).send('WebTheme not found.');
			}
		});
	});
};