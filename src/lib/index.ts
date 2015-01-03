/// <reference path="../../typings/bundle.d.ts" />

module.exports = (config: any) => {
	require('./web')(config);
	require('./api')(config);
};