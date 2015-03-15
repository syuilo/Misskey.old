/// <reference path="../typings/bundle.d.ts" />

import mysql = require('mysql');
var config: any = require('./config');
var db: mysql.IPool = mysql.createPool(config.db);
export = db;
