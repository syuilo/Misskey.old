require! {
	'../../auth': authorize
	'../../../config': config
	'../../../models/notice': Notice
	'../../../models/status': Status
	'../../../models/status-favorite': StatusFavorite
	'../../../utils/streaming': Streamer
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	| (status-id = req.body.status_id) == null => res.api-error 400 'status_id parameter is required :('
	| _ => Status.find-one {id: status-id} (, target-status) ->
			| !target-status? => res.api-error 404 'Post not found...'
			| !target-status.repost-from-status-id? => favorite-step req, res, app, user, target-status
			| _ => Status.find-one { id: target-status.repost-from-status-id } (, true-target-status) -> favorite-step req, res, app, user, true-target-status

function favorite-step req, res, app, user, target-status
	StatusFavorite.is-favorited target-status.id, user.id, (is-favorited) ->
		| is-favorited => res.api-error 400 'This post is already favorited :('
		| _ => StatusFavorite.insert { status-id: target-status.id, user-id: user.id } (, favorite) ->
			target-status
				..favorites-count++
				..update ->
			Post.build-response-object target-post, res.api-render
			content =
				status: target-status
				user: user.filt!
			Notice.insert { app-id: config.web-client-id, type: \favorite, content: JSON.stringify content, user-id: target-status.user-id } (, notice) ->
				Streamer.publish 'userStream:' + target-status.user-id, JSON.stringify do
					type: \notice
					value: notice
