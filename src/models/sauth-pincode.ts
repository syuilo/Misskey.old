/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = SAuthPincode;

class SAuthPincode {
	appId: number;
	code: string;
	userId: number;

	public constructor(pincode: any) {
		this.appId = pincode.app_id;
		this.code = pincode.code;
		this.userId = pincode.user_id;
	}

	public static generateCode(): string {
		return Math.floor(Math.random() * 10000000).toString();
	}

	public static create(appId: number, userId: number, callback: (sauthPincode: SAuthPincode) => void): void {
		var code = SAuthPincode.generateCode();
		db.query('insert into sauth_pincodes (app_id, user_id, code) values (?, ?, ?)',
			[appId, userId, code],
			(err, sauthPincodes) => callback(new SAuthPincode(sauthPincodes[0])));
	}

	public static find(code: string, callback: (sauthPincode: SAuthPincode) => void): void {
		db.query("select * from sauth_pincodes where code = ?",
			[code],
			(err, sauthPincodes) => callback(new SAuthPincode(sauthPincodes[0])));
	}

    public destroy(callback?: () => void): void {
		db.query('delete from sauth_request_tokens where code = ?',
			[this.code],
			callback);
	}
}
