/// <reference path="../../typings/bundle.d.ts" />

import mysql = require('mysql');

module.exports = (config: any) => {
	return mysql.createPool(config.db);
};