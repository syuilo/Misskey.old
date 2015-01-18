/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = AccessToken;

import crypto = require('crypto');

var createHash = (() => {
	var sha1sum = crypto.createHash('sha256');
	return (text: string) => {
		sha1sum.update(text);
		return sha1sum.digest('hex');
	};
})();

class AccessToken {
	appId: number;
	token: string;
	userId: number;

	public constructor(accessToken: any) {
		if (accessToken !== void 0) {
			this.appId = accessToken.app_id;
			this.token = accessToken.token;
			this.userId = accessToken.user_id;
		}
	}

	public static generateToken(userId: number): string {
		return createHash(userId + (+new Date()).toString());
	}

	public static create(appId: number, userId: number, callback: (accessToken: AccessToken) => void): void {
		var token = AccessToken.generateToken(userId);
		db.query('insert into accesstokens (app_id, user_id, token) values (?, ?, ?)',
			[appId, userId, token],
			(err: any, accessTokens: any[]) => callback(new AccessToken(accessTokens[0])));
	}

	public static find(accessToken: string, callback: (accessToken: AccessToken) => void): void {
		db.query("select * from accesstokens where token = ?",
			[accessToken],
			(err: any, accessTokens: any[]) => callback(accessTokens[0] != null ? new AccessToken(accessTokens[0]) : null));
	}

	public static findByUserId(userId: number, callback: (accessTokens: AccessToken[]) => void): void {
		db.query("select * from accesstokens where user_id = ?",
			[userId],
			(err: any, accessTokens: any[]) => callback(accessTokens[0] != null ? accessTokens.map((accessToken) => new AccessToken(accessToken)) : null));
	}

	public static findByAppId(appId: number, callback: (accessTokens: AccessToken[]) => void): void {
		db.query("select * from accesstokens where app_id = ?",
			[appId],
			(err: any, accessTokens: any[]) => callback(accessTokens[0] != null ? accessTokens.map((accessToken) => new AccessToken(accessToken)) : null));
	}

	public static findByUserIdAndAppId(userId: number, appId: number, callback: (accessToken: AccessToken) => void): void {
		db.query("select * from accesstokens where user_id = ?, app_id = ?",
			[userId, appId],
			(err: any, accessTokens: any[]) => callback(accessTokens[0] != null ? new AccessToken(accessTokens[0]) : null));
    }

    public destroy(callback?: () => void): void {
        db.query('delete from accesstokens where token = ?',
            [this.token],
            callback);
    }
}
