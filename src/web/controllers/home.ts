/// <reference path="../../../typings/bundle.d.ts" />

import jade = require('jade');
import Application = require('../../models/application');
import User = require('../../models/user');
import Post = require('../../models/post');
import conf = require('../../config');

export = render;

var render = (req: any, res: any): void => {
	Post.getTimeline(req.me.id, 30, null, null, (posts: Post[]) => {
		Post.generateTimeline(posts, (timeline: Post[]) => {
			res.display(req, res, 'home', {
				timeline: timeline,
				timelineHtml: jade.compileFile('../views/templates/timeline.jade', {
					
				})({
					posts: timeline
				}),
				parseText: parseText
			});
		});
	});
};

function parseText(text: string): string {
	text = escapeHtml(text);
	text = parseURL(text);
	text = parseReply(text);
	text = parseNewLine(text);
	return text;

	function parseURL(text: string): string {
		return text.replace(/https?:\/\/[-_.!~*a-zA-Z0-9;\/?:\@&=+\$,%#]+/g,(url: string) => {
			return `<a href="${url}" target="_blank" class="url">${url}</a>`;
		});
	}

	function parseReply(text: string): string {
		return text.replace(/@([a-zA-Z0-9_]+)/g,(_: string, screenName: string) => {
			return `<a href="${conf.url}/${screenName}" target="_blank" class="screenName">@${screenName}</a>`;
		});
	}

	function parseNewLine(text: string): string {
		return text.replace(/(\r\n|\r|\n)/g, '<br>');
	}
}

function escapeHtml(text: string): string {
	return String(text)
		.replace(/&(?!\w+;)/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;')
		.replace(/"/g, '&quot;');
}