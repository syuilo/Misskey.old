/// <reference path="../../typings/bundle.d.ts" />

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

    public static create(userId: number, name: string, screenName: string, description: string, callback: (circle: Circle) => void): void {
        db.query('insert into circles (user_id, name, screen_name, description) values (?, ?, ?, ?)', [userId, name, screenName, description], (err: any, info: any) => {
            if (err) console.log(err);
            Circle.find(info.insertId, (circle: Circle) => {
                callback(circle);
            })
        });
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

    public static existScreenName(screenName: string, callback: (exist: boolean) => void): void {
        db.query('select exists (select * from circles where screen_name = ?) as exist',
            [screenName],
            (err: any, circles: any[]) => callback(circles[0].exist == 1 ? true : false));
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