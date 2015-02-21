/// <reference path="../../../typings/bundle.d.ts" />

import fs = require('fs');
import path = require('path');
import express = require('express');
import gm = require('gm');
import User = require('../../models/user');
import UserImage = require('../../models/user-image');
import Post = require('../../models/post');
import PostImage = require('../../models/post-image');
import TalkMessage = require('../../models/talk-message');
import TalkMessageImage = require('../../models/talk-message-image');
import WebTheme = require('../../models/webtheme');
import config = require('../../config');

export = router;

var router = (app: express.Express): void => {
	/* User icon */
	app.get('/img/icon/:idOrSn',(req: any, res: any) => {
		if (req.params.idOrSn.match(/^[0-9]+$/)) {
			UserImage.find(Number(req.params.idOrSn),(userImage: UserImage) => {
				display(userImage);
			});
		} else {
			User.findByScreenName(req.params.idOrSn,(user: User) => {
				if (user == null) {
					res.status(404).send('User not found.');
					return;
				}
				UserImage.find(user.id,(userImage: UserImage) => {
					display(userImage);
				});
			});
		}

		var display = (userImage: UserImage) => {
			if (userImage != null) {
				var imageBuffer = userImage.icon != null ? userImage.icon : fs.readFileSync(path.resolve(__dirname + '/../resources/images/icon_default.jpg'));
				sendImage(req, res, imageBuffer);
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	/* User header */
	app.get('/img/header/:idOrSn',(req: any, res: any) => {
		if (req.params.idOrSn.match(/^[0-9]+$/)) {
			UserImage.find(Number(req.params.idOrSn),(userImage: UserImage) => {
				display(userImage);
			});
		} else {
			User.findByScreenName(req.params.idOrSn,(user: User) => {
				if (user == null) {
					res.status(404).send('User not found.');
					return;
				}
				UserImage.find(user.id,(userImage: UserImage) => {
					display(userImage);
				});
			});
		}

		var display = (userImage: UserImage) => {
			if (userImage != null) {
				var imageBuffer = userImage.header != null ? userImage.header : fs.readFileSync(path.resolve(__dirname + '/../resources/images/header_default.jpg'));
				sendImage(req, res, imageBuffer);
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	/* User wallpaper */
	app.get('/img/wallpaper/:idOrSn',(req: any, res: any) => {
		if (req.params.idOrSn.match(/^[0-9]+$/)) {
			UserImage.find(Number(req.params.idOrSn),(userImage: UserImage) => {
				display(userImage);
			});
		} else {
			User.findByScreenName(req.params.idOrSn,(user: User) => {
				if (user == null) {
					res.status(404).send('User not found.');
					return;
				}
				UserImage.find(user.id,(userImage: UserImage) => {
					display(userImage);
				});
			});
		}

		var display = (userImage: UserImage) => {
			if (userImage != null) {
				var imageBuffer = userImage.wallpaper != null ? userImage.wallpaper : fs.readFileSync(path.resolve(__dirname + '/../resources/images/wallpaper_default.jpg'));
				sendImage(req, res, imageBuffer);
			} else {
				res.status(404).send('User not found.');
			}
		};
	});

	/* Post */
	app.get('/img/post/:id',(req: any, res: any) => {
		PostImage.find(req.params.id,(postImage: PostImage) => {
			if (postImage != null) {
				var imageBuffer = postImage.image;
				sendImage(req, res, imageBuffer);
			} else {
				res.status(404).send('Image not found.');
			}
		});
	});

	/* Talk message */
	app.get('/img/talk-message/:id',(req: any, res: any) => {
		TalkMessageImage.find(req.params.id,(talkMessageImage: TalkMessageImage) => {
			if (talkMessageImage != null) {
				var imageBuffer = talkMessageImage.image;
				sendImage(req, res, imageBuffer);
			} else {
				res.status(404).send('Image not found.');
			}
		});
	});

	/* Webtheme thumbnail */
	app.get('/img/webtheme_thumbnail/:id',(req: any, res: any) => {
		WebTheme.find(req.params.id,(webtheme: WebTheme) => {
			if (webtheme != null) {
				var imageBuffer = webtheme.thumbnail;
				sendImage(req, res, imageBuffer);
			} else {
				res.status(404).send('WebTheme not found.');
			}
		});
	});
};

function sendImage(req: any, res: any, image: Buffer) {
	if (req.query.blur != null) {
		try {
			var options = JSON.parse(req.query.blur.replace(/([a-zA-Z]+)\s?:\s?([^,}"]+)/g, '"$1":$2'));
			gm(image)
				.blur(options.radius, options.sigma)
				.compress('jpeg')
				.quality(80)
				.toBuffer('jpeg',(error: any, buffer: Buffer) => {
				if (error) throw error;
				res.set('Content-Type', 'image/jpeg');
				res.send(buffer);
			});
		} catch (e) {
			res.status(400).send(e);
		}
	} else {
		res.set('Content-Type', 'image/jpeg');
		res.send(image);
	}
}