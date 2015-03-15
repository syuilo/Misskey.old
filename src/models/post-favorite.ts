/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
import Post = require('./post');
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
            (err: any, info: any) => {
                if (err) console.log(err);
                PostFavorite.find(info.insertId,(postFavorite: PostFavorite) => {
                    callback(postFavorite);
                });
            });
    }

    public static find(id: number, callback: (postFavorite: PostFavorite) => void): void {
        db.query("select * from post_favorites where id = ?",
            [id],
            (err: any, postFavorites: any[]) => callback(postFavorites[0] != null ? new PostFavorite(postFavorites[0]) : null));
    }

    public static isFavorited(postId: number, userId: number, callback: (favorite: boolean) => void): void {
        db.query("select exists (select * from post_favorites where post_id = ? and user_id = ?) as exist",
            [postId, userId],
            (err: any, postFavorites: any[]) => callback(postFavorites[0].exist == 1 ? true : false));
    }

    public static findByPostId(postId: number, callback: (postFavorites: PostFavorite[]) => void): void {
        db.query("select * from post_favorites where post_id = ?",
            [postId],
            (err: any, postFavorites: any[]) => callback(postFavorites.length != 0 ? postFavorites.map((postFavorite) => new PostFavorite(postFavorite)) : null));
    }

    public static findByUserId(userId: number, callback: (postFavorites: PostFavorite[]) => void): void {
        db.query("select * from post_favorites where user_id = ?",
            [userId],
            (err: any, postFavorites: any[]) => callback(postFavorites.length != 0 ? postFavorites.map((postFavorite) => new PostFavorite(postFavorite)) : null));
    }

    public static getPostFavorites(postId: number, limit: number, offset: number, callback: (postFavorites: PostFavorite[]) => void): void {
        var q: string, p: any;
        if (limit === null) {
            q = "select * from post_favorites where post_id = ? order by id desc";
            p = [postId];
        } else {
            q = "select * from post_favorites where post_id = ? order by id desc limit ?, ?";
            p = [postId, offset, limit];
        }
        db.query(q, p,(err: any, postFavorites: any[]) => callback(postFavorites.map((postFavorite) => new PostFavorite(postFavorite))));
    }

    public static getMyFavorites(userId: number, limit: number, offset: number, callback: (postFavorites: PostFavorite[]) => void): void {
        var q: string, p: any;
        if (limit === null) {
            q = "select * from post_favorites where user_id = ? order by id desc";
            p = [userId];
        } else {
            q = "select * from post_favorites where user_id = ? order by id desc limit ?, ?";
            p = [userId, offset, limit];
        }
        db.query(q, p,(err: any, postFavorites: any[]) => callback(postFavorites.map((postFavorite) => new PostFavorite(postFavorite))));
    }

    public static getPostFavoritesCount(postId: number, callback: (favoritesCount: number) => void): void {
        db.query("select count(*) as count from post_favorites where post_id = ?",
            [postId],
            (err: any, postFavorites: any[]) => callback(postFavorites[0].count));
    }

    public destroy(callback?: () => void): void {
        db.query('delete from post_favorites where post_id = ? and user_id = ?"',
            [this.postId, this.userId],
            callback);
    }
}
