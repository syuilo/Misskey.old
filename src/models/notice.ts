/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
import moment = require("moment");
export = Notice;

class Notice {
	appId: number;
	content: string;
	createdAt: string;
	id: number;
	userId: number;

	public constructor(notice: any) {
		this.appId = notice.app_id;
		this.content = notice.content;
		this.createdAt = moment(notice.created_at).format('YYYY/MM/DD HH:mm:ss Z');
		this.id = notice.id;
		this.userId = notice.user_id;
	}

	public static create(appId: number, content: string, userId: number, callback: (notice: Notice) => void): void {
		db.query('insert into notices (app_id, content, user_id) values (?, ?, ?)',
			[appId, content, userId],
			(err: any, info: any) => {
				if (err) console.log(err);
				Notice.find(info.insertId,(notice: Notice) => {
					callback(notice);
				});
			});
	}

	public static find(id: number, callback: (notice: Notice) => void): void {
		db.query("select * from notices where id = ?",
			[id],
			(err: any, notices: any[]) => callback(new Notice(notices[0])));
	}

	public static findByuserId(userId: number, callback: (notices: Notice[]) => void): void {
		db.query("select * from notices where user_id = ? order by created_at desc",
			[userId],
			(err: any, notices: any[]) => callback(notices.length != 0 ? notices.map((notice) => new Notice(notice)) : null));
	}

	public destroy(callback: () => void): void {
		db.query('delete from notices where id = ?"',
			[this.id],
			callback);
	}
}