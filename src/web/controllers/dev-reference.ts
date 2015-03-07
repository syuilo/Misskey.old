/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import jade = require('jade');
import fs = require('fs');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	var path = __dirname + "/../../reference/bad_request_error.jade";
	if (req.query.q) {
		if (req.query.q.indexOf("..", 0) == -1) {
			var items: string[] = req.query.q.split("-");
			var tempPath = __dirname + "/../../reference/apis/" + items.join("/") + ".jade";
			//ファイルの存在確認
			if (fs.existsSync(tempPath)) {
				path = tempPath;
			}
		}
	}
	var compiler = jade.compileFile(path, {});
	var html = compiler();
	res.display(req, res, "dev-reference", {
		passedHtml: html,
	});
};
