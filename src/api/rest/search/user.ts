/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');
import Streamer = require('../../../utils/streaming');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var authorize = require('../../auth');

var searchUser = (req: any, res: APIResponse) => {
	if (req.query.query == null) {
		res.apiError(400, 'query parameter is required :(');
		return;
	}
	var query = req.query.query;

	User.searchByScreenName(query, 5,(users: User[]) => {
		async.map(users,(user: User, mapNext: any) => {
			mapNext(null, user.filt());
		},(err: any, results: any[]) => {
				res.apiRender(results);
			});
	});
}

module.exports = searchUser;