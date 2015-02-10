/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = PostMention;

class PostMention {
	id: number;
	postId: number;
	userId: number;

	public constructor(postMention: any) {
		this.id = postMention.id;
		this.postId = postMention.post_id;
		this.userId = postMention.user_id;
	}

	public static create(postId: number, userId: number, callback: (postMention: PostMention) => void): void {
		db.query('insert into post_mentions (post_id, user_id) values (?, ?)',
			[postId, userId],
			(err: any, info: any) => {
				if (err) console.log(err);
				PostMention.find(info.insertId,(postMention: PostMention) => {
					callback(postMention);
				});
			});
	}

	public static find(id: number, callback: (postMention: PostMention) => void): void {
		db.query("select * from post_mentions where id = ?",
			[id],
			(err: any, postmentions: any[]) => callback(new PostMention(postmentions[0])));
	}

	public static findByUserId(userId: number, limit: number, sinceId: number, maxId: number, callback: (postMentions: PostMention[]) => void): void {
		var q: string, p: any;
		if ((sinceId === null) && (maxId === null)) {
			q = "select * from post_mentions where user_id = ? order by id desc limit ?";
			p = [userId, limit];
		} else if (sinceId !== null) {
			q = "select * from post_mentions where user_id = ? and postId > ? order by id desc limit ?";
			p = [userId, sinceId, limit];
		} else if (maxId !== null) {
			q = "select * from post_mentions where user_id = ? and postId < ? order by id desc limit ?";
			p = [userId, maxId, limit];
		}
		db.query(q, p, (err: any, postMentions: any[]) => callback(postMentions.map((postMention) => new PostMention(postMention))));
	}

	public static findByPostId(postId: number, limit: number, offset: number, callback: (postMentions: PostMention[]) => void): void {
		var q: string, p: any;
		if (limit === null) {
			q = "select * from post_mentions where post_id = ? order by id desc";
			p = [postId];
		} else {
			q = "select * from post_mentions where post_id = ? order by id desc limit ?, ?";
			p = [postId, offset, limit];
		}
		db.query(q, p, (err: any, postMentions: any[]) => callback(postMentions.map((postMention) => new PostMention(postMention))));
	}
}
