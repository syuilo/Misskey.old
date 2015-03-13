/// <reference path="../../../typings/bundle.d.ts" />

import APIResponse = require('../api-response');
import User = require('../../models/user');

var screenNameAvailable = (req: any, res: APIResponse) => {
	if (req.query.screen_name == null) {
		res.apiError(400, 'screen_name parameter is required :(');
		return;
	}
	var screenName = req.query.screen_name.replace(/^@/, '');
	if (isEmpty(req.query.screen_name)) {
		res.apiError(400, 'Empty screen_name');
		return;
	}
	User.findByScreenName(screenName,(user: User) => {
		res.apiRender(user != null);
	});
}

function isEmpty(text: string): boolean {
	return text === '';
}


module.exports = screenNameAvailable;
