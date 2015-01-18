/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = SAuthRequestToken;

import crypto = require('crypto');

var createHash = (() => {
	var sha1sum = crypto.createHash('sha256');
	return (text: string) => {
		sha1sum.update(text);
		return sha1sum.digest('hex');
	};
})();

class SAuthRequestToken {
	appId: number;
	id: number;
	isInvalid: boolean;
	token: string;

	public constructor(sauthRequestToken: any) {
		this.appId = sauthRequestToken.app_id;
		this.id = sauthRequestToken.id;
		this.isInvalid = sauthRequestToken.invalid;
		this.token = sauthRequestToken.token;
	}

	public static generateToken(appId: number): string {
		return createHash(appId + (+new Date()).toString());
	}

	public static create(appId: number, callback: (sauthRequestToken: SAuthRequestToken) => void): void {
		var token = SAuthRequestToken.generateToken(appId);
		db.query('insert into sauth_request_tokens (app_id, token) values (?, ?)',
			[appId, token],
			(err, sauthRequestTokens) => callback(new SAuthRequestToken(sauthRequestTokens[0])));
	}

	public static find(requestToken: string, callback: (sauthRequestToken: SAuthRequestToken) => void): void {
		db.query("select * from sauth_request_tokens where token = ?",
			[requestToken],
			(err, sauthRequestTokens) => callback(new SAuthRequestToken(sauthRequestTokens[0])));
	}

    public update(callback?: () => void): void {
		db.query('update sauth_request_tokens set invalid = ? where token = ?',
			[this.isInvalid, this.token],
			callback);
    }

    public destroy(callback?: () => void): void {
        db.query("delete from sauth_request_tokens where token=?",
            [this.token],
            callback);
    }
    
}
