/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
import async = require('async');
import Application = require('./application');
import User = require('./user');
import UserFollowing = require('./user-following');
import PostMention = require('./post-mention');
import CircleMember = require('./circle-member');
export = Post;

class Post {
	appId: number;
	createdAt: string;
	id: number;
	inReplyToPostId: number;
	image: string;
	isImageAttached: boolean;
	text: string;
	userId: number;

	public constructor(post: any) {
		this.appId = post.app_id;
		this.createdAt = post.created_at;
		this.id = post.id;
		this.inReplyToPostId = post.in_reply_to_post_id;
		this.image = post.image;
		this.isImageAttached = Boolean(post.is_image_attached);
		this.text = post.text;
		this.userId = post.user_id;
	}

	public static create(appId: number, inReplyToPostId: number, image: Buffer, isImageAttached: Boolean, text: string, userId: number, callback: (post: Post) => void): void {
		db.query('insert into posts (app_id, in_reply_to_post_id, image, is_image_attached, text, user_id) values (?, ?, ?, ?, ?, ?)',
			[appId, inReplyToPostId, image, isImageAttached, text, userId],
			(err: any, info: any) => {
				if (err) console.log(err);
				Post.find(info.insertId,(post: Post) => {
					callback(post);
				});
			});
	}

	public static find(id: number, callback: (post: Post) => void): void {
		db.query("select * from posts where id = ?",
			[id],
			(err: any, posts: any[]) => callback(posts[0] != null ? new Post(posts[0]) : null));
	}

	public static getUserPostsCount(userId: number, callback: (postsCount: number) => void): void {
		db.query("select count(*) as count from posts where user_id = ?",
			[userId],
			(err: any, count: any[]) => callback(count[0].count));
	}

	public static findByUserId(userId: number, limit: number, sinceId: number, maxId: number, callback: (posts: Post[]) => void): void {
		var q: string, p: any;
		if ((sinceId === null) && (maxId === null)) {
			q = "select * from posts where user_id = ? order by id desc limit ?";
			p = [userId, limit];
		} else if (sinceId !== null) {
			q = "select * from posts where user_id = ? and id > ? order by id desc limit ?";
			p = [userId, sinceId, limit];
		} else if (maxId !== null) {
			q = "select * from posts where user_id = ? and id < ? order by id desc limit ?";
			p = [userId, maxId, limit];
		}
		db.query(q, p,(err: any, posts: any[]) => callback(posts.length != 0 ? posts.map((post) => new Post(post)) : null));
	}

	public static getTimeline(userId: number, limit: number, sinceId: number, maxId: number, callback: (posts: Post[]) => void): void {
		UserFollowing.findByFollowerId(userId,(userFollowings: UserFollowing[]) => {
			var followingsStr: string = null;
			if (userFollowings != null && userFollowings.length !== 0) {
				var followingsStrs: string[] = [];
				userFollowings.forEach((userFollowing: UserFollowing) => {
					followingsStrs.push(userFollowing.followeeId.toString());
				});
				followingsStr = followingsStrs.join(',');
			} else {
				callback(null);
				return;
			}
			var q: string, p: any;
			if ((sinceId === null) && (maxId === null)) {
				q = "select * from posts where " + (followingsStr !== null ? "user_id in (" + followingsStr + ") or " : "") + "user_id = ? order by id desc limit ?";
				p = [userId, limit];
			} else if (sinceId !== null) {
				q = "select * from posts where (" + (followingsStr !== null ? "user_id in (" + followingsStr + ") or " : "") + "user_id = ?) and id > ? order by id desc limit ?";
				p = [userId, sinceId, limit];
			} else if (maxId !== null) {
				q = "select * from posts where (" + (followingsStr !== null ? "user_id in (" + followingsStr + ") or " : "") + "user_id = ?) and id < ? order by id desc limit ?";
				p = [userId, maxId, limit];
			}
			db.query(q, p,(err: any, posts: any[]) => callback(posts.length != 0 ? posts.map((post) => new Post(post)) : null));
		});
	}

	public static getCircleTimeline(circleId: number, limit: number, sinceId: number, maxId: number, callback: (posts: Post[]) => void): void {
		CircleMember.findByCircleId(circleId, null,(circleMembers: CircleMember[]) => {
			var circleMembersStr = circleMembers.join(',');
			var q: string, p: any;
			if ((sinceId === null) && (maxId === null)) {
				q = "select * from posts where user_id in (" + circleMembersStr + ") order by id desc limit ?";
				p = [limit];
			} else if (sinceId !== null) {
				q = "select * from posts where user_id in (" + circleMembersStr + ") and id > ? order by id desc limit ?";
				p = [sinceId, limit];
			} else if (maxId !== null) {
				q = "select * from posts where user_id in (" + circleMembersStr + ") and id < ? order by id desc limit ?";
				p = [maxId, limit];
			}
			db.query(q, p,(err: any, posts: any[]) => callback(posts.length != 0 ? posts.map((post) => new Post(post)) : null));
		});
	}

	public static getMentions(userId: number, limit: number, sinceId: number, maxId: number, callback: (posts: Post[]) => void): void {
		PostMention.findByUserId(userId, limit, sinceId, maxId,(postMentions: PostMention[]) => {
			if (postMentions != null) {
				async.map(postMentions,(mention: PostMention, next: any) => {
					Post.find(mention.postId,(post: Post) => {
						next(null, post);
					});
				},(err: any, results: Post[]) => {
						callback(results);
					});
			} else {
				callback(null);
			}
		});
	}
}
