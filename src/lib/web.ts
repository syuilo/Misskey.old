import express = require('express');
import mysql = require('mysql');

module.exports = (config: any, db: mysql.IPool) => {
	var webServer = express();
	webServer.set('config', config);
	webServer.set('db', db);

	webServer.listen(config.port.web);
};