/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = TalkMessage;

class TalkMessage {
	appId: number;
	createdAt: string;
	id: number;
	image: string;
	isImageAttached: boolean;
	text: string;
	toUserId: number;
	userId: number;

	public constructor(message: any) {
		this.appId = message.app_id;
		this.createdAt = message.created_at;
		this.id = message.id;
		this.image = message.image;
		this.isImageAttached = Boolean(message.is_image_attached);
		this.text = message.text;
		this.toUserId = message.to_user_id;
		this.userId = message.user_id;
	}

	public static create(
		appId: number,
		userId: number,
		toUserId: number,
		text: string,
		isImageAttached: Boolean,
		image: Buffer,
		callback: (talkMessage: TalkMessage) => void): void {
		db.query('insert into talk_messages (app_id, user_id, to_user_id, text, is_image_attached, image) values (?, ?, ?, ?, ?, ?)',
			[appId, userId, toUserId, text, isImageAttached, image],
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

	public static findByUserIdAndToUserId(
		userId: number,
		toUserId: number,
		limit: number,
		sinceId: number,
		maxId: number,
		callback: (messages: TalkMessage[]) => void): void {
		var q: string, p: any;
		if ((sinceId === null) && (maxId === null)) {
			q = "select * from talk_messages where user_id = ? and to_user_id = ? order by id desc limit ?";
			p = [userId, toUserId, limit];
		} else if (sinceId !== null) {
			q = "select * from talk_messages where user_id = ? and to_user_id = ? and id > ? order by id desc limit ?";
			p = [userId, toUserId, sinceId, limit];
		} else if (maxId !== null) {
			q = "select * from talk_messages where user_id = ? and to_user_id = ? and id < ? order by id desc limit ?";
			p = [userId, toUserId, maxId, limit];
		}
		db.query(q, p,(err: any, messages: any[]) => callback(messages.length != 0 ? messages.map((message) => new TalkMessage(message)) : null));
	}

	public update(callback: () => void = () => { }): void {
		db.query('update talk_messages set text = ? where id =?',
			[this.text, this.id],
			callback);
	}

	public destroy(callback: () => void = () => { }): void {
		db.query('delete from talk_messages where id = ?',
			[this.id],
			callback);
	}
}
