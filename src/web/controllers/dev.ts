/// <reference path="../../../typings/bundle.d.ts" />

import async = require('async');
import Application = require('../../models/application');
import jade = require('jade');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	if (req.query.q) {
		var items: string[] = req.query.q.split("-");
		var path = (req.query.q.indexOf("..", 0) != -1)
			? (__dirname + "/../../reference/bad_request_error.jade")
			: (__dirname + "/../../reference/apis/" + items.join("/") + ".jade");
		var compiler = jade.compileFile(path, {});
		var html = compiler();
		res.display(req, res, "dev_reference", {
			passedHtml: html,
		});
	} else {
		async.series([
			(callback: any) => {
				if (req.login) {
					Application.findByUserId(req.me.id, (apps: Application[]) => {
						callback(null, apps != null ? apps : []);
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
