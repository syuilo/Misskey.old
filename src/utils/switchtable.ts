/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import Post = require('../models/post');
import PostImage = require('../models/post-image');

for (var i = 62870; i < 141326; i++) {
	Post.find(i,(post: Post) => {
		if (post != null) {
			if (post.isImageAttached) {
				PostImage.create(post.id, post.image,(image: PostImage) => {
					console.log(post.id);
				});
			}
		}
	});
}