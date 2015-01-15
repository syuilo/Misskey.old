/// <reference path="../../typings/bundle.d.ts" />

import mysql = require('mysql');
var config: any = require('../../../../config.json');

export = mysql.createPool(config.db);
