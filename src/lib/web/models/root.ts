/// <reference path="../../../../typings/bundle.d.ts" />


import express = require('express');
import async = require('async');
import Application = require('../../model/application');
import User = require('../../model/user');
import Post = require('../../model/post');

export = render;

var render = (req: any, res: any): void => {
	if (req.login) {
		Post.getTimeline(req.me.id, 30, null, null, (posts: Post[]) => {
			Post.generateTimeline(posts, (timeline: Post[]) => {
				res.display(req, res, 'home', {
					timeline: timeline
				});
			});
		});
	} else {
		res.display(req, res, 'entrance', {});
	}
};
