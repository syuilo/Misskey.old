/// <reference path="../../../typings/bundle.d.ts" />

import db = require('../db');
export = Circle;

class Circle {
    createdAt: string;
    description: string;
    icon: string;
    id: number;
    name: string;
    screenName: string;
    userId: number;

    public constructor(circle: any) {
        this.createdAt = circle.created_at;
        this.description = circle.description;
        this.icon = circle.icon;
        this.id = circle.id;
        this.name = circle.name;
        this.screenName = circle.screen_name;
        this.userId = circle.user_id;
    }

    public static create(userId: number, name: string, description: string, callback: (circle: Circle) => void): void {
        db.query('insert into circles (user_id, name, description) values (?, ?, ?)',
            [userId, name, description],
            (err, circles) => callback(new Circle(circles[0])));
    }

    public static find(id: number, callback: (circle: Circle) => void): void {
        db.query("select * from circles where id = ?",
            [id],
            (err, circles) => callback(new Circle(circles[0])));
    }

    public static findByUserId(userId: number, callback: (postFavorites: Circle) => void): void {
        db.query("select * form circles where user_id = ?",
            [userId],
            (err, circles) => callback(new Circle(circles[0])));        
    }

    public update(callback?: () => void): void {
        db.query("update circles set name=?, description=?, icon=? where id=?",
            [this.name, this.description, this.icon, this.id],
            callback);
    }

    public destroy(callback?: () => void): void {
        db.query('delete from circle_join_requests where id = ?',
            [this.id],
            callback);
    }
}