/// <reference path="../../../typings/bundle.d.ts" />

import mongoose = require('mongoose');

var db = mongoose.connect('mongodb://localhost/Misskey');

var userSchema = new mongoose.Schema({
	bio: { type: String },
	birthday: { type: String },
	color: { type: String },
	comment: { type: String },
	createdAt: { type: Date, default: Date.now, required: true },
	emailaddress: { type: Number },
	exp: { type: String },
	firstName: { type: String },
	gender: { type: String },
	isPlused: { type: Boolean },
	isSuspended: { type: Boolean },
	lang: { type: String },
	lastName: { type: String },
	location: { type: String },
	lv: { type: Number },
	name: { type: String },
	password: { type: String },
	screenName: { type: String, required: true },
	url: { type: String },
	usingWebThemeId: { type: Number }
});

var model = db.model('User', userSchema);
export = model;
