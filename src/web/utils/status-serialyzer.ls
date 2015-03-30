require! {
	'../../models/application': Application
	'../../models/user': User
	'../../models/status': Status
	'../../models/status-favorite': StatusFavorite
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'./timeline-serialize-more-talk': serialize-talk
	'../../config'
}

module.exports = (status, me, callback) ->
	function get-app(status, callback)
		Application.find-by-id status.app-id, (, app) ->
			#delete app.consumer-key
			#delete app.callback-url
			status.app = app.to-object!
			callback status
	
	function get-user(status, callback)
		User.find-by-id status.user-id, (, user) ->
			status.user = user.to-object!
			callback status
	
	function get-is-favorited(status, me, callback)
		if me?
			status-check-favorited me.id, status.id .then (is-favorited) ->
				console.log 'is-favorited:' + is-favorited
				callback is-favorited
		else
			callback null
	
	function get-is-reposted(status, me, callback)
		if me?
			status-check-reposted me.id, status.id .then (is-reposted) ->
				next null, is-reposted
		else
			callback null
	
	function get-reply(status, callback)
		switch
		| !status.is-reply => callback status
		| _ =>
			Status.find-by-id status.in-reply-to-status-id, (, reply-status) ->
				| !reply-status? =>
					status.is-reply = no
					callback status
				| _ =>
					reply-status.is-reply = reply-status.in-reply-to-status-id?
					status.reply = reply-status
					User.find-by-id reply-status.user-id, (, reply-user) ->
						status.reply.user = reply-user
						if reply-status.is-reply
							serialize-talk reply-status, (talk) ->
								status.more-talk = talk
								callback status
						else
							callback status
	
	function serialyze-repost(status, callback)
		switch
		| status.repost-from-status-id? =>
			Status.find-by-id status.repost-from-status-id, (, repost-from-post) ->
				| repost-from-post? =>
					_repost-from-post = repost-from-post
						..is-repost-to-status = yes
						..source = status
					User.find-by-id post.user-id, (, reposted-by-user) ->
						_repost-from-post.reposted-by-user = reposted-by-user
						callback _repost-from-post
				| _ =>
					status.is-repost-to-status = no
					callback status
		| _ =>
			status.is-repost-to-status = no
			callback status
	
	status .= to-object!
	status.is-reply = status.in-reply-to-status-id?
	status <- serialyze-repost status
	status <- get-app status
	status <- get-user status
	status <- get-reply status
	status.is-favorited = no
	status.is-reposted = no
	callback status
	