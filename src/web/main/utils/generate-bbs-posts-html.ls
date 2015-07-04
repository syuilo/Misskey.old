require! {
	jade
	'./bbs-posts-serialyzer'
	'../../../config'
}

module.exports = (posts, callback) ->
	post-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/bbs-post/post.jade"
	posts-compiler = jade.compile-file "#__dirname/../views/dynamic-parts/bbs-post/posts.jade"
	if posts?
		bbs-posts-serialyzer posts .then (serialized-posts) ->
			post-htmls = map do
				(post) ->
					post-compiler do
						post: post
						config: config.public-config
				serialized-posts
			html = posts-compiler do
				posts: post-htmls
			callback html
	else
		html = timeline-compiler do
			posts: null
		callback html