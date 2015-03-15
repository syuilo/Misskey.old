/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
import moment = require("moment");
import Application = require('./application');
import User = require('./user');
export = TalkMessage;

class TalkMessage {
	appId: number;
	createdAt: string;
	id: number;
	isDeleted: boolean;
	isImageAttached: boolean;
	isModified: boolean;
	isReaded: boolean;
	text: string;
	otherpartyId: number;
	userId: number;

	public constructor(message: any) {
		this.appId = message.app_id;
		this.createdAt = moment(message.created_at).format('YYYY/MM/DD HH:mm:ss Z');
		this.id = message.id;
		this.isDeleted = Boolean(message.is_deleted);
		this.isImageAttached = Boolean(message.is_image_attached);
		this.isModified = Boolean(message.is_modified);
		this.isReaded = Boolean(message.is_readed);
		this.text = message.text;
		this.otherpartyId = message.otherparty_id;
		this.userId = message.user_id;
	}

	public static create(
		appId: number,
		userId: number,
		otherpartyId: number,
		text: string,
		isImageAttached: Boolean,
		callback: (talkMessage: TalkMessage) => void): void {
		db.query('insert into talk_messages (app_id, user_id, otherparty_id, text, is_image_attached) values (?, ?, ?, ?, ?)',
			[appId, userId, otherpartyId, text, isImageAttached],
			(err: any, info: any) => {
				if (err) console.log(err);
				TalkMessage.find(info.insertId,(talkMessage: TalkMessage) => {
					callback(talkMessage);
				});
			});
	}

	public static find(id: number, callback: (talkMessage: TalkMessage) => void): void {
		db.query("select * from talk_messages where id = ?",
			[id],
			(err: any, messages: any[]) => callback(messages[0] != null ? new TalkMessage(messages[0]) : null));
	}

	public static findByUserIdAndOtherpartyId(
		userId: number,
		otherpartyId: number,
		limit: number,
		sinceId: number,
		maxId: number,
		callback: (messages: TalkMessage[]) => void): void {
		var q: string, p: any;
		if ((sinceId === null) && (maxId === null)) {
			q = "select * from talk_messages where user_id = ? and otherparty_id = ? order by id desc limit ?";
			p = [userId, otherpartyId, limit];
		} else if (sinceId !== null) {
			q = "select * from talk_messages where user_id = ? and otherparty_id = ? and id > ? order by id desc limit ?";
			p = [userId, otherpartyId, sinceId, limit];
		} else if (maxId !== null) {
			q = "select * from talk_messages where user_id = ? and otherparty_id = ? and id < ? order by id desc limit ?";
			p = [userId, otherpartyId, maxId, limit];
		}
		db.query(q, p,(err: any, messages: any[]) => callback(messages.length != 0 ? messages.map((message) => new TalkMessage(message)) : null));
	}

	public static getRecentMessagesInRecentTalks(userId: number, limit: number, callback: (messages: TalkMessage[]) => void): void {
		db.query("select * from (select * from talk_messages where otherparty_id = ? order by created_at desc) a group by user_id order by created_at desc limit ?",
			[userId, limit],
			(err: any, messages: any[]) => callback(messages.length != 0 ? messages.map((message) => new TalkMessage(message)) : null));
	}

	public static getAllUnreadCount(userId: number, callback: (unreadCount: number) => void): void {
		db.query("select count(*) as count from talk_messages where otherparty_id = ? and is_readed = 0",
			[userId],
			(err: any, messages: any[]) => callback(messages[0].count));
	}

	public static getUserUnreadCount(userId: number, otherpartyId: number, callback: (unreadCount: number) => void): void {
		db.query("select count(*) as count from talk_messages where otherparty_id = ? and user_id = ? and is_readed = 0",
			[userId, otherpartyId],
			(err: any, messages: any[]) => callback(messages[0].count));
	}

	public update(callback: () => void = () => { }): void {
		db.query('update talk_messages set text=?, is_modified=?, is_deleted=?, is_readed=? where id=?',
			[this.text, this.isModified, this.isDeleted, this.isReaded, this.id],
			callback);
	}

	public destroy(callback: () => void = () => { }): void {
		db.query('delete from talk_messages where id = ?',
			[this.id],
			callback);
	}

	public static buildResponseObject(talkMessage: TalkMessage, callback: (obj: any) => void): void {
		var obj: any = talkMessage;
		Application.find(talkMessage.appId,(app: Application) => {
			delete app.callbackUrl;
			delete app.consumerKey;
			obj.app = app;
			User.find(talkMessage.userId,(user: User) => {
				obj.user = user.filt();
				User.find(obj.otherpartyId,(otherparty: User) => {
					obj.otherparty = otherparty.filt();
					callback(obj);
				});
			});
		});
	}
}
