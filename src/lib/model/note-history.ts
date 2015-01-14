/// <reference path="../../../typings/bundle.d.ts" />

import db = require('../db');
export = NoteHistory;

class NoteHistory {
    id: number;
    noteId: number;
    userId: number;
    createdAt: string;
    content: string;
    message: string;
    hash: string;

    public constructor(noteHistory: any) {
        this.id = noteHistory.id;
        this.noteId = noteHistory.note_id;
        this.userId = noteHistory.user_id;
        this.createdAt = noteHistory.created_at;
        this.content = noteHistory.content;
        this.message = noteHistory.message;
        this.hash = noteHistory.hash;
    }

    public static create(hash: number, noteId: number, userId: number, content: string, message: string, callback: (noteHistory: NoteHistory) => void): void {
        db.query("insert into note_histories (hash, note_id, user_id, content, message) values (?, ?, ?, ?, ?)",
            [hash, noteId, userId, content, message],
            (err, noteHistories) => callback(new NoteHistory(noteHistories[0])));
    }
    
    public static find(id: number, callback: (noteHistory: NoteHistory) => void): void {
        db.query("select * from note_histories where id = ?",
            [id],
            (err, noteHistories) => callback(new NoteHistory(noteHistories[0])));
    }

    public static findByHashAndNoteId(hash: string, noteId: number, callback: (noteHistory: NoteHistory) => void): void {
        db.query("select * from note_histories where hash = ? and note_id = ?",
            [hash, noteId],
            (err, noteHistories) => callback(new NoteHistory(noteHistories[0])));
    }

    public static findByNoteId(noteId: number, callback: (noteHistory: NoteHistory) => void): void {
        db.query("select * from note_histories where note_id = ? order by created_at desc",
            [noteId],
            (err, noteHistories) => callback(new NoteHistory(noteHistories[0])));
    }
}