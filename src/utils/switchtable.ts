/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import User = require('../models/user');
import UserImage = require('../models/user-image');

for (var i = 1; i < 11792; i++) {
	User.find(i,(user: User) => {
		if (user != null) {
			UserImage.create(user.id,(image: UserImage) => {
				if (user.icon != null) image.icon = user.icon;
				if (user.header != null) image.header = user.header;
				if (user.wallpaper != null) image.wallpaper = user.wallpaper;
				image.update(() => {
					console.log(user.id);
				});
			});
		}
	});
}