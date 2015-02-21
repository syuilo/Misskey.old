/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = TalkMessageImage;

class TalkMessageImage {
	messageId: number;
	image: Buffer;

	public constructor(messageImage: any) {
		this.messageId = messageImage.message_id;
		this.image = messageImage.image;
	}

	public static create(messageId: number, image: Buffer, callback: (messageImage: TalkMessageImage) => void): void {
		db.query('insert into talk_message_images (message_id, image) values (?, ?)',
			[messageId, image],
			(err: any, info: any) => {
				if (err) console.log(err);
				TalkMessageImage.find(messageId,(messageImage: TalkMessageImage) => {
					callback(messageImage);
				});
			});
	}

	public static find(messageId: number, callback: (messageImage: TalkMessageImage) => void): void {
		db.query("select * from talk_message_images where message_id = ?",
			[messageId],
			(err: any, messageImages: any[]) => callback(messageImages[0] != null ? new TalkMessageImage(messageImages[0]) : null));
	}

}