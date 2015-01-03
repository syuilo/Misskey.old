import express = require('express');
import mysql = require('mysql');

module.exports = (config: any, db: mysql.IPool) => {
	var apiServer = express();
	apiServer.set('config', config);
	apiServer.set('db', db);
	
	apiServer.listen(config.port.api);
};