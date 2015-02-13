/// <reference path="../../../../typings/bundle.d.ts" />

import APIResponse = require('../../api-response');

var teapotCoffee = (req: any, res: APIResponse) => {
	res.apiError(418, "I'm a teapot.");
}

module.exports = teapotCoffee;