require! {
	'../../../config': config
	'../../../models/notice': Notice
	'../../../models/post': Post
	'../../../models/post-favorite': PostFavorite
	'../../../utils/streaming': Streamer
}

authorize = require '../../auth'

favorite-step = (req, res, app, user, target-post) ->
	PostFavorite.is-favorited target-post.id, user.id (is-favorited) ->
		if is-favorited
			res.api-error 400 'This post is already favorited :)'
			return

		PostFavorite.create target-post.id, user.id (favorite) ->
			target-post.favorites-count++;
			target-post.update ->
			Post.build-response-object target-post, (obj) ->
				res.api-render obj
			content = {}
			content.post = target-post
			content.user = user.filt!
			Notice.create config.web-client-id, 'favorite', JSON.stringify content, target-post.user-id, (notice) ->
				Streamer.publish 'userStream:' + target-post.user-id, JSON.stringify do
					type: 'notice'
					value: notice

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.body.post_id == null
			res.api-error 400 'post_id parameter is required :('
			return
		post-id = req.body.post_id

		Post.find post-id, (target-post) ->
			if target-post == null
				res.api-error 404 'Post not found...'
				return

			if target-post.repost-from-post-id == null
				favorite-step req, res, app, user, target-post
			else
				Post.find target-post.repost-from-post-id, (true-target-post) ->
					favorite-step req, res, app, user, true-target-post

