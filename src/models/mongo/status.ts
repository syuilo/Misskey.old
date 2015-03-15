/// <reference path="../../../typings/bundle.d.ts" />

import mongoose = require('mongoose');
import config = require('../../config');

var db = mongoose.connect(config.mongo.uri, config.mongo.options);

var statusSchema = new mongoose.Schema({
	content: { type: String, required: true },
	createdAt: { type: Date, default: Date.now, required: true },
	userId: { type: Number, required: true },
});

var model = db.model('Status', statusSchema);
export = model;
