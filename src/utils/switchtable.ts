/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import Post = require('../models/post');
import TalkMessage = require('../models/talk-message');
import TalkMessageImage = require('../models/talk-message-image');

for (var i = 1; i < 175; i++) {
	TalkMessage.find(i, (message: TalkMessage) => {
		if (message != null && message.isImageAttached) {
			TalkMessageImage.create(message.id, message.image, (image: TalkMessageImage) => {
				console.log(message.id);
			});
		}
	});
}
