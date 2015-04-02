require! {
	'../../auth': authorize
	'../../../config'
	'../../../models/status': Status
	'../../../models/status-favorite': StatusFavorite
	'../../../models/utils/status-check-favorited'
	'../../../models/utils/serialize-status'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(status-id = req.body\status-id)? => res.api-error 400 'status-id parameter is required :('
	| _ => Status.find-by-id status-id, (, target-status) ->
			| !target-status? => res.api-error 404 'Post not found...'
			| target-status.repost-from-status-id? => # Repostなら対象をRepost元に差し替え
				Status.find-by-id target-status.repost-from-status-id, (, true-target-status) ->
					favorite-step req, res, app, user, true-target-status
			| _ => favorite-step req, res, app, user, target-status

function favorite-step req, res, app, user, target-status
	status-check-favorited target-status.id, user.id, (is-favorited) ->
		| is-favorited => res.api-error 400 'This post is already favorited :('
		| _ => 
			favorite = new StatusFavorite do
				status-id: target-status.id
				user-id: user.id
			favorite.save ->
				target-status
					..favorites-count++
					..save (err) ->
						serialize-status target-status, res.api-render
