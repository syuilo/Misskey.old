/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = User;

class User {
	badge: string;
	bio: string;
	color: string;
	comment: string;
	createdAt: string;
	credit: number;
	exp: number;
	header: Buffer;
	icon: Buffer;
	id: number;
	isPremium: boolean;
	isSuspended: boolean;
	lang: string;
	location: string;
	lv: number;
	mailAddress: string;
	name: string;
	password: string;
	screenName: string;
	tag: string;
	tutorial: number;
	twitterAccessToken: string;
	twitterAccessTokenSecret: string;
	url: string;
	wallpaper: Buffer;
	webThemeId: number;

	public constructor(user: any) {
		this.badge = user.badge;
		this.bio = user.bio;
		this.color = user.color;
		this.comment = user.comment;
		this.createdAt = user.created_at;
		this.credit = user.credit;
		this.exp = user.exp;
		this.header = user.header;
		this.icon = user.icon;
		this.id = user.id;
		this.isPremium = Boolean(user.is_premium);
		this.isSuspended = Boolean(user.is_suspended);
		this.lang = user.lang;
		this.location = user.location;
		this.lv = user.lv;
		this.mailAddress = user.mail_address;
		this.name = user.name;
		this.password = user.password;
		this.screenName = user.screen_name;
		this.tag = user.tag;
		this.tutorial = user.tutorial;
		this.twitterAccessToken = user.twitter_access_token;
		this.twitterAccessTokenSecret = user.twitter_access_token_secret;
		this.url = user.url;
		this.wallpaper = user.wallpaper;
		this.webThemeId = user.web_theme_id;
	}

	public static create(screenName: string, password: string, tutorial: number, name: string, callback: (user: User) => void): void {
		db.query('insert into users (screen_name, password, tutorial, name) values (?, ?, ?, ?)',
			[screenName, password, tutorial, name],
			(err: any, users: any[]) => callback(new User(users[0])));
	}

	public static find(id: number, callback: (user: User) => void): void {
		db.query("select * from users where id = ?",
			[id],
			(err: any, users: any[]) => callback(users[0]!= null ? new User(users[0]): null));
	}

	public static findNoImages(id: number, callback: (user: User) => void): void {
		db.query("select id, created_at, screen_name, password, mail_address, tutorial, is_suspended, is_premium, credit, lang, badge, name, comment, color, web_theme_id, bio, url, location, tag, exp, lv from users where id = ?",
			[id],
			(err: any, users: any[]) => {
				if (users[0] != null) {
					var user: any = users[0];
					user.icon = null;
					user.header = null;
					user.wallpaper = null;
					callback(new User(user));
				} else {
					callback(null)
				}
			});
	}

	public static findByScreenName(screenName: string, callback: (user: User) => void): void {
		db.query("select * from users where screen_name = ?",
			[screenName],
			(err: any, users: any[]) => callback(users[0] != null ? new User(users[0]) : null));
	}

	public static getLevelRanking(callback: (users: User[]) => void): void {
		db.query('select * from users where is_suspended = 0 order by level desc limit 10',
			(err: any, users: any[]) => callback(users.map((user) => new User(user))));
	}

	public filt(): any {
		var obj: any = {};
		obj.badge = this.badge;
		obj.bio = this.bio;
		obj.color = this.color;
		obj.comment = this.comment;
		obj.createdAt = this.createdAt;
		obj.credit = this.credit;
		obj.exp = this.exp;
		obj.id = this.id;
		obj.lang = this.lang;
		obj.location = this.location;
		obj.lv = this.lv;
		obj.name = this.name;
		obj.screenName = this.screenName;
		obj.tag = this.tag;
		obj.url = this.url;
		return obj;
	}

    public update(callback?: () => void): void {
		db.query('update users set screen_name =?, password =?, mail_address =?, credit =?, tutorial =?, is_suspended =?, name =?, comment =?, lang =?, badge =?, icon =?, color =?, header =?, wallpaper =?, web_theme_id =?, bio =?, url =?, location =?, tag =?, exp =?, lv =?, twitter_access_token =?, twitter_access_token_secret =? where id =?',
			[this.screenName, this.password, this.mailAddress, this.credit, this.tutorial, this.isSuspended, this.name, this.comment, this.lang, this.badge, this.icon, this.color, this.header, this.wallpaper, this.webThemeId, this.bio, this.url, this.location, this.tag, this.exp, this.lv, this.twitterAccessToken, this.twitterAccessTokenSecret, this.id],
			callback);
	}
}