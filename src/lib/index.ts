/// <reference path="../../typings/bundle.d.ts" />

module.exports = (config: any) => {
	var db = require('./db');
	require('./web')(config, db);
	require('./api')(config, db);
};