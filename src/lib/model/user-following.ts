/// <reference path="../../../typings/bundle.d.ts" />

import db = require('../db');
export = UserFollowing;

class UserFollowing {
	createdAt: string;
	followeeId: number;
	followerId: number;

	public constructor(following: any) {
		this.createdAt = following.created_at;
		this.followeeId = following.followee_id;
		this.followerId = following.follower_id;
	}

	public static create(followeeId: number, followerId: number, callback: (userFollowing: UserFollowing) => void): void {
		db.query('insert into user_followings (followee_id, follower_id) values (?, ?)',
			[followeeId, followerId],
			(err, userFollowings) => callback(new UserFollowing(userFollowings[0])));
	}

	public static find(followeeId: number, followerId: number, callback: (userFollowing: UserFollowing) => void): void {
		db.query("select * from user_followings where followee_id = ? and follower_id = ?",
			[followeeId, followerId],
			(err, userFollowings) => callback(new UserFollowing(userFollowings[0])));
	}

	public static isFollowing(meId: number, targetId: number, callback: (following: boolean) => void): void {
		db.query("select * from user_followings where followee_id = ? and follower_id = ?",
			[targetId, meId],
			(err, userFollowings) => callback(userFollowings.length !== 0));
	}

	public static findByFolloweeId(followeeId: number, callback: (userFollowings: UserFollowing[]) => void): void {
		db.query("select * from user_followings where followee_id = ? order by created_at desc",
			[followeeId],
			(err, userFollowings: any[]) => callback(userFollowings.map((userFollowing) => new UserFollowing(userFollowing))));
	}

	public static findByFollowerId(followerId: number, callback: (userFollowings: UserFollowing[]) => void): void {
		db.query("select * from user_followings where follower_id = ? order by created_at desc",
			[followerId],
			(err, userFollowings: any[]) => callback(userFollowings.map((userFollowing) => new UserFollowing(userFollowing))));
	}

	public static getFollowersCount(meId: number, callback: (followersCount: number) => void): void {
		db.query("select count(*) from user_followings where followee_id = ?",
			[meId],
			(err, userFollowings) => callback(userFollowings[0]));
	}

	public static getFollowingsCount(meId: number, callback: (followersCount: number) => void): void {
		db.query("select count(*) from user_followings where follower_id = ?",
			[meId],
			(err, userFollowings) => callback(userFollowings[0]));
	}

	public static getFriends(meId: number, limit: number, callback: (userFollowings: UserFollowing[]) => void): void {
		db.query("select * from user_followings where follower_id = ? and followee_id in (select follower_id from user_followings where followee_id = ? oreder by created_at desc) order by created_at desc limit ?",
			[meId, meId, limit],
			(err, userFollowings: any[]) => callback(userFollowings.map((userFollowing) => new UserFollowing(userFollowing))));
	}

    public destroy(callback?: () => void): void {
		db.query('delete from user_followings where followee_id = ? and follower_id = ?"',
			[this.followeeId, this.followerId],
			callback);
	}
}
