/// <reference path="../../../typings/bundle.d.ts" />

import db = require('./db');
export = PostFavorite;

class PostFavorite {
	createdAt: string;
	id: number;
	postId: number;
	userId: number;

	public constructor(postFavorite: any) {
		this.createdAt = postFavorite.createdAt;
		this.id = postFavorite.id;
		this.postId = postFavorite.postId;
		this.userId = postFavorite.user_id;
	}

	public static create(postId: number, userId: number, callback: (postFavorite: PostFavorite) => void): void {
		db.query('insert into post_favorites (post_id, user_id) values (?, ?)',
			[postId, userId],
			(err, postFavorites) => callback(new PostFavorite(postFavorites[0])));
	}

	public static isFavorited(postId: number, userId: number, callback: (favorite: boolean) => void): void {
		db.query("select * from post_favorites where post_id = ? and user_id = ?",
			[postId, userId],
			(err, postFavorites) => callback(postFavorites.length !== 0));
	}

	public static findByPostId(postId: number, limit: number, offset: number, callback: (postFavorites: PostFavorite[]) => void): void {
		var q, p;
		if (limit === null) {
			q = "select * from post_favorites where post_id = ? order by id desc";
			p = [postId];
		} else {
			q = "select * from post_favorites where post_id = ? order by id desc limit ?, ?";
			p = [postId, offset, limit];
		}
		db.query(q, p, (err, postFavorites: any[]) => callback(postFavorites.map((postFavorite) => new PostFavorite(postFavorite))));
	}

	public static findByUserId(userId: number, limit: number, offset: number, callback: (postFavorites: PostFavorite[]) => void): void {
		var q, p;
		if (limit === null) {
			q = "select * from post_favorites where user_id = ? order by id desc";
			p = [userId];
		} else {
			q = "select * from post_favorites where user_id = ? order by id desc limit ?, ?";
			p = [userId, offset, limit];
		}
		db.query(q, p, (err, postFavorites: any[]) => callback(postFavorites.map((postFavorite) => new PostFavorite(postFavorite))));
	}

    public destroy(callback?: () => void): void {
		db.query('delete from post_favorites where post_id = ? and user_id = ?"',
			[this.postId, this.userId],
			callback);
	}
}
