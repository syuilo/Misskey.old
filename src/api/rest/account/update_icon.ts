/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import jpeg = require('jpeg-js');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var accountUpdateIcon = (req: any, res: APIResponse) => {
	authorize(req, res,(user: User, app: Application) => {
		if (Object.keys(req.files).length === 1) {
			var path = req.files.image.path;
			var image = jpeg.encode(jpeg.decode(fs.readFileSync(path)), 70).data;
			fs.unlink(path);

			user.icon = image;
			user.update(() => {
				res.apiRender(user.filt());
			});
		}
	});
}

module.exports = accountUpdateIcon;