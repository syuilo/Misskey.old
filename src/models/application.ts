/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
import moment = require("moment");
export = Application;

import crypto = require('crypto');

var createHash = (() => {
	var sha1sum = crypto.createHash('sha256');
	return (text: string) => {
		sha1sum.update(text);
		return sha1sum.digest('hex');
	};
})();

function getNowTimestamp(): number {
	return +new Date;
}

class Application {
	id: number;
	name: string;
	userId: number;
	createdAt: string;
	consumerKey: string;
	callbackUrl: string;
	description: string;
	developerName: string;
	developerWebsite: string;
	isSuspended: boolean;

	public constructor(app: any) {
		this.id = app.id;
		this.name = app.name;
		this.userId = app.user_id;
		this.createdAt = moment(app.created_at).format('YYYY/MM/DD HH:mm:ss Z');
		this.consumerKey = app.consumer_key;
		this.callbackUrl = app.callback_url;
		this.description = app.description;
		this.developerName = app.developer_name;
		this.developerWebsite = app.developer_website;
		this.isSuspended = Boolean(app.is_suspended);
	}

	public static generateCK(userId: number): string {
		return createHash(userId + getNowTimestamp().toString());
	}

	public static create(name: string, userId: number, callbackUrl:string, description: string, developerName: string, developerWebsite: string, callback: (app: Application) => void): void {
		var ck = Application.generateCK(userId);

		Application.findByName(name, (app: Application) => {
			if (app == null) {
				db.query('insert into applications (name, user_id, consumer_key, callback_url, description, developer_name, developer_website) values (?, ?, ?, ?, ?, ?, ?)',
					[name, userId, ck, callbackUrl, description, developerName, developerWebsite],
					(err: any, info: any) => {
						if (err) console.log(err);
						Application.find(info.insertId, (app: Application) => {
							callback(app);
						});
					});
			} else {
				callback(null);
			}
		});
	}

	public static find(id: number, callback: (app: Application) => void): void {
		db.query("select * from applications where id = ?",
			[id],
			(err: any, apps: any[]) => callback(apps[0] != null ? new Application(apps[0]) : null));
	}

	public static findByConsumerKey(consumerKey: string, callback: (app: Application) => void): void {
		db.query("select * from applications where consumer_key = ?",
			[consumerKey],
			(err: any, apps: any[]) => callback(apps[0] != null ? new Application(apps[0]) : null));
	}

	public static findByName(name: string, callback: (app: Application) => void): void {
		db.query("select * from applications where name = ?",
			[name],
			(err: any, apps: any[]) => callback(apps[0] != null ? new Application(apps[0]) : null));
	}

	public static findByUserId(userId: number, callback: (apps: Application[]) => void): void {
		db.query("select * from applications where user_id = ?",
			[userId],
			(err: any, apps: any[]) => callback(apps.length != 0 ? apps.map((app) => new Application(app)) : null));
	}

	public update(callback: () => void): void {
		db.query('update applications set name = ?, consumer_key = ?, callback_url = ?, description = ?, developer_name = ?, developer_website = ?, is_suspended = ?, where id = ?',
			[this.name, this.consumerKey, this.callbackUrl, this.description, this.developerName, this.developerWebsite, this.isSuspended, this.id],
			callback);
	}
}
