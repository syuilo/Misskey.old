/// <reference path="../../../../typings/bundle.d.ts" />

import bcrypt = require('bcrypt');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import User = require('../../../models/user');
import UserImage = require('../../../models/user-image');
import UserFollowing = require('../../../models/user-following');
import config = require('../../../config');

var accountCreate = (req: any, res: APIResponse) => {
	if (req.body.screen_name == null) {
		res.apiError(400, 'post_id parameter is required :(');
		return;
	}
	var screenName = req.body.screen_name;
	screenName = screenName.replace(/^@/, '');
	if (screenName.length < 4 ||
		screenName.length > 20 ||
		screenName.match(/^[0-9]+$/) ||
		!screenName.match(/^[a-zA-Z0-9_]+$/)) {
		res.apiError(400, 'screen_name invalid format');
		return;
	}

	if (req.body.name == null) {
		res.apiError(400, 'name parameter is required :(');
		return;
	}
	var name = req.body.name;
	if (name == '') {
		res.apiError(400, 'name invalid format');
		return;
	}

	if (req.body.password == null) {
		res.apiError(400, 'password parameter is required :(');
		return;
	}
	var password = req.body.password;
	if (password.length < 8) {
		res.apiError(400, 'password invalid format');
		return;
	}

	if (req.body.color == null) {
		res.apiError(400, 'color parameter is required :(');
		return;
	}
	var color = req.body.color;
	if (!color.match(/#[a-fA-F0-9]{6}/)) {
		res.apiError(400, 'color invalid format');
		return;
	}

	User.findByScreenName(screenName,(user: User) => {
		if (user != null) {
			res.apiError(500, 'This screen name is already used.');
			return;
		}

		var salt = bcrypt.genSaltSync(16);
		var hashPassword = bcrypt.hashSync(password, salt);

		User.create(screenName, hashPassword, name, color,(createdUser: User) => {
			if (createdUser == null) {
				res.apiError(500, 'Sorry, register failed. please try again.');
				return;
			}

			UserImage.create(createdUser.id,(userImage: UserImage) => {
				AccessToken.create(config.webClientId, createdUser.id,(accessToken: AccessToken) => {
					UserFollowing.create(1, createdUser.id,(userFollowing: UserFollowing) => {
						UserFollowing.create(createdUser.id, 1,(userFollowing: UserFollowing) => {
							res.apiRender(createdUser.filt());
						});
					});
				});
			});
		});
	});
}

module.exports = accountCreate;