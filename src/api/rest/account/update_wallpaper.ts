/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import gm = require('gm');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountUpdateWallpaper = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (Object.keys(req.files).length === 1) {
			var path = req.files.image.path;
			gm(path)
				.compress('jpeg')
				.quality(80)
				.toBuffer('jpeg',(error: any, buffer: Buffer) => {
				if (error) throw error;
				fs.unlink(path);
				user.wallpaper = buffer;
				user.update(() => {
					res.apiRender(user.filt());
				});
			});
		}
	});
}

module.exports = accountUpdateWallpaper;