/// <reference path="../../../typings/bundle.d.ts" />

import mongoose = require('mongoose');
import config = require('../../config');

var db = mongoose.connect(config.mongo.uri, config.mongo.options);

var userSchema = new mongoose.Schema({
	bio: { type: String },
	birthday: { type: String },
	color: { type: String, default: '#ff005c', required: true },
	comment: { type: String },
	createdAt: { type: Date, default: Date.now, required: true },
	emailaddress: { type: Number },
	exp: { type: String },
	firstName: { type: String },
	gender: { type: String },
	isPlused: { type: Boolean, default: false },
	isSuspended: { type: Boolean, default: false },
	lang: { type: String, default: 'ja', required: true },
	lastName: { type: String },
	location: { type: String },
	lv: { type: Number },
	name: { type: String },
	password: { type: String, required: true },
	screenName: { type: String, required: true },
	url: { type: String },
	usingWebThemeId: { type: Number }
});

var model = db.model('User', userSchema);
export = model;
