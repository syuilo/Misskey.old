/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import jade = require('jade');
import fs = require('fs');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {

	//typeパラメータが有効なクエリ文字列かどうか
	var isValidType = true;

	if (req.query.type) {
		switch (req.query.type) {

			case 'ref':
				//API Reference
				var path = __dirname + "/../../reference/bad_request_error.jade";
				if (req.query.q.indexOf("..", 0) == -1) {
					var items: string[] = req.query.q.split("-");
					var tempPath = __dirname + "/../../reference/apis/" + items.join("/") + ".jade";
					//ファイルの存在確認
					fs.readFile(tempPath, 'utf-8', function (error, data) {
						if (!error) {
							path = tempPath;
						}
					});
				}
				var compiler = jade.compileFile(path, {});
				var html = compiler();
				res.display(req, res, "dev_reference", {
					passedHtml: html,
				});
				break;

			case 'app':
				//My Applications
				isValidType = false;//仮
				break;

			case 'style':
				//My Styles
				isValidType = false;//仮
				break;

			default:
				isValidType = false;
				break;
		}

	} else {
		isValidType = false;
	}

	if (!isValidType) {
		//通常の開発者センターを表示
		async.series([
			(callback: any) => {
				if (req.login) {
					Application.findByUserId(req.me.id, (apps: Application[]) => {
						callback(null, apps);
					});
				} else {
					callback(null, []);
				}
			}],
			(err: any, results: any) => {
				res.display(req, res, 'dev', {
					apps: results[0],
				});
			});
	}
};
