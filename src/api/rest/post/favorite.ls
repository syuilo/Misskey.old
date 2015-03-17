require! {
	'../../../config': config
	'../../../models/notice': Notice
	'../../../models/post': Post
	'../../../models/post-favorite': PostFavorite
	'../../../utils/streaming': Streamer
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| (post-id = req.body.post_id) == null => res.api-error 400 'post_id parameter is required :('
	| _ => Post.find post-id, (target-post) ->
			| target-post == null => res.api-error 404 'Post not found...'
			| target-post.repost-from-post-id == null => favorite-step req, res, app, user, target-post
			| _ => Post.find target-post.repost-from-post-id, (true-target-post) -> favorite-step req, res, app, user, true-target-post

favorite-step = (req, res, app, user, target-post) ->
	PostFavorite.is-favorited target-post.id, user.id, (is-favorited) ->
		| is-favorited => res.api-error 400 'This post is already favorited :('
		| _ => PostFavorite.create target-post.id, user.id, (favorite) ->
			target-post
				..favorites-count++
				..update ->
			Post.build-response-object target-post, res.api-render
			content =
				post: target-post
				user: user.filt!
			Notice.create config.web-client-id, 'favorite', JSON.stringify content, target-post.user-id, (notice) ->
				Streamer.publish 'userStream:' + target-post.user-id, JSON.stringify do
					type: 'notice'
					value: notice
