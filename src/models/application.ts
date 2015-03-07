/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = Application;

import crypto = require('crypto');

var createHash = (() => {
	var sha1sum = crypto.createHash('sha256');
	return (text: string) => {
		sha1sum.update(text);
		return sha1sum.digest('hex');
	};
})();

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
	isSuspended: boolean
	
	public constructor(app: any) {
		if (app != null) {
			this.id = app.id;
			this.name = app.name;
			this.userId = app.userId;
			this.createdAt = app.created_at;
			this.consumerKey = app.consumer_key;
			this.callbackUrl = app.callback_url;
			this.description = app.description;
			this.developerName = app.developerName;
			this.isSuspended = Boolean(app.isSuspended);
		}
	}

	public static generateCK(userId: number) {
		createHash(userId + (+new Date()).toString())
	}

	public static create(name: string, userId: number, description: string, callback: (app: Application) => void): void {
		var ck = Application.generateCK(userId);
		db.query('insert into applications (name, user_id, consumer_key, description) values (?, ?, ?, ?)',
			[name, userId, ck, description],
			(err: any, apps: any[]) => callback(new Application(apps[0])));
	}

	public static find(id: number, callback: (app: Application) => void):  void {
		db.query("select * from applications where id = ?",
			[id],
			(err: any, apps: any[]) => callback(apps[0] != null ? new Application(apps[0]) : null));
	}

	public static findByConsumerKey(consumerKey: string, callback: (app: Application) => void):  void {
		db.query("select * from applications where consumer_key = ?",
			[consumerKey],
			(err: any, apps: any[]) => callback(apps[0] != null ? new Application(apps[0]) : null));
	}

	public static findByUserId(userId: number, callback: (apps: Application[]) => void): void {
		db.query("select * from applications where user_id = ?",
			[userId],
			(err: any, apps: any[]) => callback(apps[0] != null ? apps.map((app) => new Application(app)) : []));
	}

    public update(callback?: () => void): void {
        db.query('update applications set name = ?, consumer_key = ?, callback_url = ?, description = ?, is_suspended, where id = ?',
            [this.name, this.consumerKey, this.callbackUrl, this.description, this.isSuspended, this.id],
            callback);
    }
}
