/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import gm = require('gm');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');
import UserImage = require('../../../models/user-image');

var authorize = require('../../auth');

var accountUpdateIcon = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		UserImage.find(user.id,(userImage: UserImage) => {
			if (Object.keys(req.files).length === 1) {
				var path = req.files.image.path;
				gm(path)
					.compress('jpeg')
					.quality(80)
					.toBuffer('jpeg',(error: any, buffer: Buffer) => {
					if (error) throw error;
					fs.unlink(path);
					userImage.icon = buffer;
					userImage.update(() => {
						res.apiRender(user.filt());
					});
				});
			}
		});
	});
}

module.exports = accountUpdateIcon;