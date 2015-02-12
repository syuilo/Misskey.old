/// <reference path="../../../../typings/bundle.d.ts" />

import fs = require('fs');
import APIResponse = require('../../api-response');
import AccessToken = require('../../../models/access-token');
import Application = require('../../../models/application');
import User = require('../../../models/user');

var teapotCoffee = (req: any, res: APIResponse) => {
	res.apiError(418, "I'm a teapot.");
}

module.exports = teapotCoffee;