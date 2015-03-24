require! {
	async
	'../../models/application': Application
	'../../models/user': User
	'../../models/status': Status
	'../../models/status-favorite': StatusFavorite
	'../../models/status-check-favorited'
	'../../models/status-check-reposted'
	'./timeline-serialize-more-talk': serialize-talk
	'../../config': config
}

module.exports = (statuses, me, callback) ->
	function get-app(status)
		(next) ->
			Application.find-by-id status.app-id, (, app) ->
				delete app.consumer-key
				delete app.callback-url
				next null, app
	
	function get-user(status)
		(next) ->
			User.find-by-id status.user-id (user) ->
				next null, user
	
	function get-is-favorited(status, me)
		(next) ->
			if me?
				status-check-favorited me.id, status.id .then (is-favorited) ->
					next null, is-favorited
			else
				next null, null
	
	function get-is-reposted(status, me)
		(next) ->
			if me?
				status-check-reposted me.id, status.id .then (is-reposted) ->
					next null, is-reposted
			else
				next null, null
	
	function get-reply(status)
		(next) ->
			| !status.is-reply => next null, null
			| _ =>
				Status.find-by-id status.in-reply-to-status-id, (, reply-status) ->
					| !reply-status? =>
						status.is-reply = no
						next null, null
					| _ =>
						reply-status.is-reply = reply-status.in-reply-to-status-id != 0 && reply-status.in-reply-to-status-id != null
						status.reply = reply-status
						User.find-by-id reply-status.user-id, (, reply-user) ->
							status.reply.user = reply-user
							if reply-status.is-reply
								serialize-talk reply-status, (talk) ->
									status.more-talk = talk
									next null, null
							else
								next null, null
	
	async.map do
		statuses
		(status, map-next) -> # Analyze repost
			| status.repost-from-status-id? && status.repost-from-status-id != 0 =>
				Status.find status.repost-from-status-id, (repost-from-post) ->
					| repost-from-post? =>
						_repost-from-post = repost-from-post
							..is-repost-to-post = yes
							..source = status
						User.find-by-id post.user-id, (, reposted-by-user) ->
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
							get-app status
							get-user status
							get-is-favorited status, me
							get-is-reposted status, me
							get-reply status
						]
						(err, results) ->
							status.app = results.0
							status.user = results.1
							status.is-favorited = results.2
							status.is-reposted = results.3
							map-next null, status
				(err, results) ->
					callback results