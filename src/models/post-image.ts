/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = PostImage;

class PostImage {
	postId: number;
	image: Buffer;

	public constructor(postImage: any) {
		this.postId = postImage.post_id;
		this.image = postImage.image;
	}

	public static create(postId: number, image: Buffer, callback: (postImage: PostImage) => void): void {
		db.query('insert into post_images (user_id, image) values (?, ?)',
			[postId, image],
			(err: any, info: any) => {
				if (err) console.log(err);
				PostImage.find(postId,(postImage: PostImage) => {
					callback(postImage);
				});
			});
	}

	public static find(postId: number, callback: (postImage: PostImage) => void): void {
		db.query("select * from post_images where post_id = ?",
			[postId],
			(err: any, postImages: any[]) => callback(postImages[0] != null ? new PostImage(postImages[0]) : null));
	}

}