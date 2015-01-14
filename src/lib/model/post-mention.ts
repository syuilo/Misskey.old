/// <reference path="../../../typings/bundle.d.ts" />

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
			(err, postMentions) => callback(new PostMention(postMentions[0])));
	}

	public static findByUserId(userId: number, limit: number, offset: number, callback: (postMentions: PostMention[]) => void): void {
		var q, p;
		if (limit === null) {
			q = "select * from post_mentions where user_id = ? order by id desc";
			p = [userId];
		} else {
			q = "select * from post_mentions where user_id = ? order by id desc limit ?, ?";
			p = [userId, offset, limit];
		}
		db.query(q, p, (err, postMentions: any[]) => callback(postMentions.map((postMention) => new PostMention(postMention))));
	}

	public static findByPostId(postId: number, limit: number, offset: number, callback: (postMentions: PostMention[]) => void): void {
		var q, p;
		if (limit === null) {
			q = "select * from post_mentions where post_id = ? order by id desc";
			p = [postId];
		} else {
			q = "select * from post_mentions where post_id = ? order by id desc limit ?, ?";
			p = [postId, offset, limit];
		}
		db.query(q, p, (err, postMentions: any[]) => callback(postMentions.map((postMention) => new PostMention(postMention))));
	}
}
