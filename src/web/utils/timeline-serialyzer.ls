require! {
	async
	'../../models/application': Application
	'../../models/user': User
	'../../models/status': Status
	'../../models/status-favorite': StatusFavorite
	'./timeline-serialize-more-talk': serialize-talk
	'../../config': config
}

exports = (statuses, me, callback) ->
	async.map do
		statuses
		(status, map-next) -> # Analyze repost
			| status.repost-from-status-id? && status.repost-from-status-id != 0 =>
				Status.find status.repost-from-status-id, (repost-from-post) ->
					| repost-from-post != null =>
						_repost-from-post = repost-from-post
							..is-repost-to-post = yes
							..source = status
						User.find post.user-id (reposted-by-user) ->
							_repost-from-post.reposted-by-user = reposted-by-user
							map-next null, _repost-from-post
					| _ =>
						status.is-repost-to-post = no
						map-next null, status
			| _ =>
				status.is-repost-to-post = no
				map-next null, status
		(err, timeline-statuses) ->
			async.map do
				timeline-statuses
				(status, map-next) -> # Serialize post
					status.is-reply = status.in-reply-to-status-id != 0 && status.in-reply-to-status-id != null
					async.series do
						[
							(next) ->
								Application.find status.app-id, (app) ->
									delete app.consumer-key
									delete app.callback-url
									next null, app
							(next) ->
								User.find status.user-id (user) ->
									next null, user
							(next) ->
								if me != null
									StatusFavorite.is-favorited status.id, me.id, (is-favorited) ->
										next null, is-favorited
								else
									next null, null
							(next) ->
								if me != null
									Status.is-reposted status.id, me.id, (is-reposted) ->
										next null, is-reposted
								else
									next null, null
							(next) ->
								| !status.is-reply => next null, null
								| _ =>
									Status.find status.in-reply-to-status-id, (reply-status) ->
										| reply-status == null =>
											status.is-reply = no
											next null, null
										| _ =>
											reply-status.is-reply = reply-status.in-reply-to-status-id != 0 && reply-status.in-reply-to-status-id != null
											status.reply = reply-status
											User.find reply-status.user-id, (reply-user) ->
												status.reply.user = reply-user
												
												# Get more talk
												if reply-status.is-reply
													serialize-talk reply-status, (talk) ->
														status.more-talk = talk
														next null, null
												else
													next null, null
						]
						(err, results) ->
							status.app = results[0]
							status.user = results[1]
							status.is-favorited = results[2]
							status.is-reposted = results[3]
							map-next null, status
				(err, results) ->
					callback results