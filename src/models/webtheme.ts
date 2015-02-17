/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = WebTheme;

class WebTheme {
	id: number;
	createdAt: string;
	description: string;
	name: string;
	style: string;
	thumbnail: Buffer;
	userId: number;

	public constructor(theme: any) {
		this.id = theme.id;
		this.userId = theme.user_id;
		this.createdAt = theme.created_at;
		this.name = theme.name;
		this.description = theme.description;
		this.style = theme.style;
		this.thumbnail = theme.thumbnail;
	}

	public static create(
		userId: number,
		name: string,
		description: string,
		style: string,
		callback: (theme: WebTheme) => void): void {
		db.query('insert into web_themes (user_id, name, description, style) values (?, ?, ?, ?)',
			[userId, name, description, style],
			(err: any, info: any) => {
				if (err) console.log(err);
				WebTheme.find(info.insertId,(theme: WebTheme) => {
					callback(theme);
				});
			});
	}

	public static find(id: number, callback: (theme: WebTheme) => void): void {
		db.query("select * from web_themes where id = ?",
			[id],
			(err: any, themes: any[]) => callback(themes[0] != null ? new WebTheme(themes[0]) : null));
	}

	public static findByUserId(userId: number, callback: (themes: WebTheme[]) => void): void {
		db.query("select * from web_themes where user_id = ?",
			[userId],
			(err: any, themes: any[]) => callback(themes.length != 0 ? themes.map((theme) => new WebTheme(theme)) : null));
	}

	public update(callback: () => void = () => { }): void {
		db.query('update web_themes set description = ?, style = ? where id =?',
			[this.description, this.style, this.id],
			callback);
	}

	public destroy(callback: () => void = () => { }): void {
		db.query('delete from web_themes where id = ?',
			[this.id],
			callback);
	}
}
