/// <reference path="../../typings/bundle.d.ts" />

import config = require('../config');
import Post = require('../models/post');
import PostImage = require('../models/post-image');

for (var i = 141213; i < 141350; i++) {
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