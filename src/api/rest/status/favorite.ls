require! {
	'../../auth': authorize
	'../../../config': config
	'../../../models/notice': Notice
	'../../../models/status': Status
	'../../../models/status-favorite': StatusFavorite
	'../../../utils/streaming': Streamer
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| (post-id = req.body.post_id) == null => res.api-error 400 'post_id parameter is required :('
	| _ => Status.find-one {id: post-id} (, target-post) ->
			| !target-post? => res.api-error 404 'Post not found...'
			| !target-post.repost-from-post-id? => favorite-step req, res, app, user, target-post
			| _ => Status.find-one { id: target-post.repost-from-post-id } (, true-target-post) -> favorite-step req, res, app, user, true-target-post

function favorite-step req, res, app, user, target-post
	StatusFavorite.is-favorited target-post.id, user.id, (is-favorited) ->
		| is-favorited => res.api-error 400 'This post is already favorited :('
		| _ => StatusFavorite.insert { status-id: target-post.id, user-id: user.id } (, favorite) ->
			target-post
				..favorites-count++
				..update ->
			Post.build-response-object target-post, res.api-render
			content =
				post: target-post
				user: user.filt!
			Notice.insert { app-id: config.web-client-id, type: \favorite, content: JSON.stringify content, user-id: target-post.user-id } (, notice) ->
				Streamer.publish 'userStream:' + target-post.user-id, JSON.stringify do
					type: \notice
					value: notice
