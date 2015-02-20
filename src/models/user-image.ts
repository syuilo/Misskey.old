/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = UserImage;

class UserImage {
	userId: number;
	icon: Buffer;
	header: Buffer;
	wallpaper: Buffer;

	public constructor(userImage: any) {
		this.userId = userImage.user_id;
		this.icon = userImage.icon;
		this.header = userImage.header;
		this.wallpaper = userImage.wallpaper;
	}

	public static create(userId: number, callback: (userImage: UserImage) => void): void {
		db.query('insert into user_images (user_id) values (?)',
			[userId],
			(err: any, info: any) => {
				if (err) console.log(err);
				UserImage.find(userId,(userImage: UserImage) => {
					callback(userImage);
				});
			});
	}

	public static find(userId: number, callback: (userImage: UserImage) => void): void {
		db.query("select * from users where user_id = ?",
			[userId],
			(err: any, userImages: any[]) => callback(userImages[0] != null ? new UserImage(userImages[0]) : null));
	}

    public update(callback: () => void): void {
		db.query('update users set icon=?, header=?, wallpaper=? where user_id=?',
			[this.icon, this.header, this.wallpaper, this.userId],
			callback);
	}
}