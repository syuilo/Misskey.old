/// <reference path="../../typings/bundle.d.ts" />

import db = require('../db');
export = CircleJoinRequest;

class CircleJoinRequest {
    circleId: number;
    createdAt: string;
    id: number;
    userId: number;

    public constructor(circleJoinRequest: any) {
        this.circleId = circleJoinRequest.circle_id;
        this.createdAt = circleJoinRequest.created_at;
        this.id = circleJoinRequest.id;
        this.userId = circleJoinRequest.user_id;
    }

    public static create(circleId: number, userId: number, callback: (circleJoinRequest: CircleJoinRequest) => void): void {
        db.query("INSERT INTO circle_join_requests (circle_id, user_id) VALUES (?, ?)",
            [circleId, userId],
            (err, circleJoinRequests) => callback(new CircleJoinRequest(circleJoinRequests[0])));
    }

    public static find(id: number, callback: (circleJoinRequest: CircleJoinRequest) => void): void {
        db.query("select * from circle_join_requests where id = ?",
            [id],
            (err, circleJoinRequests) => callback(new CircleJoinRequest(circleJoinRequests[0])));
    }

    public static findByCircleId(circleId: number, limit: number, callback: (circleJoinRequest: CircleJoinRequest) => void): void {
        db.query("select * from circle_join_requests where circle_id = ? order by created_at desc" + (limit != null) ? " limit ?" : "",
            [circleId, limit],
            (err, circleJoinRequests) => callback(new CircleJoinRequest(circleJoinRequests[0])));
    }

    public static findByUserId(userId: number, limit: number, callback: (circleJoinRequest: CircleJoinRequest) => void): void {
        db.query("SELECT * FROM circle_join_requests WHERE user_id = ? ORDER BY created_at DESC" + (limit != null) ? " LIMIT ?" : "",
            [userId, limit],
            (err, circleJoinRequests) => callback(new CircleJoinRequest(circleJoinRequests[0])));
    }

    public static findByCircleIdAndUserId(circleId: number, userId: number, callback: (circleJoinRequest: CircleJoinRequest) => void): void {
        db.query("select * from circle_join_requests where circle_id = ? and user_id = ?",
            [circleId, userId],
            (err, circleJoinRequests) => callback(new CircleJoinRequest(circleJoinRequests[0])));
    }

    public destroy(callback?: () => void): void {
        db.query('delete from circle_join_requests where id = ?',
            [this.id],
            callback);
    }
}