/// <reference path="../../../typings/bundle.d.ts" />

import db = require('../db');
export = CircleMember;

class CircleMember {
    circleId: number;
    userId: number;
    createdAt: string;
    title: string;
    isMaster: boolean;
    isExecutive: boolean;
    canSelectJoinRequest: boolean;
    canExcludeMember: boolean;
    canCreateThread: boolean;
    canCreateNote: boolean;

    public constructor(circleMember: any) {
        this.circleId = circleMember.id;
        this.userId = circleMember.user_id;
        this.createdAt = circleMember.created_at;
        this.title = circleMember.title;
        this.isMaster = circleMember.is_master;
        this.isExecutive = circleMember.is_executive;
        this.canSelectJoinRequest = circleMember.can_select_join_request;
        this.canExcludeMember = circleMember.can_exclude_member;
        this.canCreateThread = circleMember.can_create_thread;
        this.canCreateNote = circleMember.can_create_note;
    }

    public static create(circleId: number, userId: number, title: string, isMaster: boolean, isExecutive: boolean, canSelectJoinRequest: boolean, canExcludeMember: boolean, canCreateThread: boolean, canCreateNote: boolean, callback: (circleMember: CircleMember) => void): void {
        db.query(
            "insert into circle_members (circle_id, user_id, title, is_master, is_executive, can_select_join_request, can_exclude_member, can_create_thread, can_create_note) values (?, ?, ?, ?, ?, ?, ?, ?, ?)",
            [circleId, userId, title, isMaster, isExecutive, canSelectJoinRequest, canExcludeMember, canCreateThread, canCreateNote],
            (err, circleMembers) => callback(new CircleMember(circleMembers[0])));
    }

    public static find(circleId: number, userId: number, callback: (circleMember: CircleMember) => void): void {
        db.query("select * from circle_members where circle_id = ? and user_id = ?",
            [circleId, userId],
            (err, circleMembers) => callback(new CircleMember(circleMembers[0])));
    }

    public static findByCircleId(circleId: number, limit: number, callback: (circleMember: CircleMember) => void): void {
        db.query("SELECT * FROM circle_members WHERE circle_id = ? ORDER BY created_at DESC" + (limit != null) ? " LIMIT ?" : "",
            [circleId, limit],
            (err, circleMembers) => callback(new CircleMember(circleMembers[0])));
    }

    public static findByUserId(userId: number, limit: number, callback: (circleMember: CircleMember) => void): void {
        db.query("SELECT * FROM circle_members WHERE user_id = ? ORDER BY created_at DESC" + (limit != null) ? " LIMIT ?" : "",
            [userId, limit],
            (err, circleMembers) => callback(new CircleMember(circleMembers[0])));
    }

    public static getMembersCount(circleId: number, limit: number, callback: (membersCount: number) => void): void {
        db.query("SELECT COUNT(*) FROM circle_members WHERE circle_id = ?",
            [circleId],
            (err, membersCounts) => callback(membersCounts[0]));
    }
    
    public update(callback?: () => void): void {
        db.query("update circle_members set title=?, is_master=?, is_executive=?, can_select_join_request=?, can_exclude_member=?, can_create_thread=?, can_create_note=? where circle_id=? and user_id=?",
            [this.title, this.isMaster, this.isExecutive, this.canSelectJoinRequest, this.canExcludeMember, this.canCreateThread, this.canCreateNote, this.circleId, this.userId],
            callback);
    }

    public destroy(callback?: () => void): void {
        db.query('delete from circle_join_requests where circle_id = ? and user_id = ?',
            [this.circleId, this.userId],
            callback);
    }
}