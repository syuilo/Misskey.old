/// <reference path="../../../typings/bundle.d.ts" />

import jade = require('jade');
import Application = require('../../models/application');
import User = require('../../models/user');
import Post = require('../../models/post');
import conf = require('../../config');

export = Timeline;

class Timeline {
	public static generateHtml(posts: Post[], callback: (timelineHtml: string) => void) {
		Timeline.selialyzeTimelineOnject(posts,(timeline: any[]) => {
			var compiler = jade.compileFile(__dirname + '/../views/templates/timeline.jade', {});
			var html = compiler({
				posts: timeline,
				url: conf.publicConfig.url,
				parseText: parseText
			})
		});
	}

	public static selialyzeTimelineOnject(posts: Post[], callback: (posts: any[]) => void): void {
		async.map(posts,(post: any, next: any) => {
			post.isReply = post.inReplyToPostId != 0 && post.inReplyToPostId != null;
			User.find(post.userId,(user: User) => {
				post.user = user;
				Application.find(post.appId,(app: Application) => {
					post.app = app;
					if (post.isReply) {
						Post.find(post.inReplyToPostId,(replyPost: any) => {
							replyPost.isReply = replyPost.inReplyToPostId != 0 && replyPost.inReplyToPostId != null;
							post.reply = replyPost;
							User.find(post.reply.userId,(replyUser: User) => {
								post.reply.user = replyUser;
								next(null, post);
							});
						});
					} else {
						next(null, post);
					}
				});
			});
		},(err: any, results: Post[]) => {
				callback(results);
			});
	}

	public static parseText(text: string): string {
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
				return `<a href="${conf.publicConfig.url}/${screenName}" target="_blank" class="screenName">@${screenName}</a>`;
			});
		}

		function parseNewLine(text: string): string {
			return text.replace(/(\r\n|\r|\n)/g, '<br>');
		}
	}

	public static escapeHtml(text: string): string {
		return String(text)
			.replace(/&(?!\w+;)/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;');
	}
}

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