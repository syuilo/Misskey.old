require! {
	async
	'../../models/post': Post
	'../../models/post-favorite': PostFavorite
	'../../models/user': User
}
module.exports = (req, res) ->
	async.series [
		(callback) -> Post.get-before-talk req.root-post.id, (posts) ->
			async.map posts, (post, next) ->
				User.find post.user-id, (user) ->
					post.user = user
					next null user
			, (err, results) -> callback null results
		(callback) ->
			| req.login => PostFavorite.is-favorited req.root-post.id, req.me.id, callback.bind null null
			| _ => callback null null
		(callback) ->
			| req.login => Post.is-reposted req.root-post.id, req.me.id, callback.bind null null
			| _ => callback null null
	], (err, [before-talks, is-favorited, is-reposted]) ->
		post = req.root-post
		post.user = req.root-user
		res.display req, res, 'post' {post, before-talks, is-favorited, is-reposted}
