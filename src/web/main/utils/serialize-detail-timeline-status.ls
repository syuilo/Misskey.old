require! {
	moment
	'../../../models/application': Application
	'../../../models/user': User
	'../../../models/status': Status
	'../../../models/utils/status-get-replies'
	'../../../models/utils/status-get-stargazers'
	'../../../models/utils/status-check-favorited'
	'../../../models/utils/status-check-reposted'
	'../../../config'
}

module.exports = (status, me, callback) ->
	function serialyze-repost(status, callback)
		switch
		| status.repost-from-status-id? =>
			Status.find-by-id status.repost-from-status-id, (, repost-from-status) ->
				| repost-from-status? =>
					_repost-from-status = repost-from-status.to-object!
						..is-repost-to-status = yes
						..source = status
					User.find-by-id status.user-id, (, reposted-by-user) ->
						reposted-by-user .= to-object!
						_repost-from-status.reposted-by-user = reposted-by-user
						callback _repost-from-status
				| _ =>
					status.is-repost-to-status = no
					callback status
		| _ =>
			status.is-repost-to-status = no
			callback status

	function get-app(status, callback)
		if status.app-id?
			Application.find-by-id status.app-id, (, app) ->
				status.app = app.to-object!
				callback status
		else
			status.app = null
			callback status

	function get-user(status, callback)
		User.find-by-id status.user-id, (, user) ->
			status.user = user.to-object!
			callback status

	function get-reply-source(status, callback)
		switch
		| !status.is-reply => callback status
		| _ =>
			Status.find-by-id status.in-reply-to-status-id, (, reply-status) ->
				| !reply-status? =>
					status.is-reply = no
					callback status
				| _ =>
					reply-status .= to-object!
					reply-status.is-reply = reply-status.in-reply-to-status-id?
					status.reply-source = reply-status
					User.find-by-id reply-status.user-id, (, reply-user) ->
						reply-user .= to-object!
						status.reply-source.user = reply-user
						callback status

	function get-replies(status, recursion, callback)
		status-get-replies status .then (replies) ->
			| !replies? => callback status
			| _ =>
				Promise.all (replies |> map (reply) ->
					new Promise (resolve, reject) ->
						if reply?
							User.find-by-id reply.user-id, (, reply-user) ->
								reply .= to-object!
								reply.is-reply = reply.in-reply-to-status-id?
								reply.user = reply-user.to-object!
								if recursion
									get-replies reply, no (serialized-reply) ->
										resolve serialized-reply
								else
									resolve reply
						else
							resolve null)
					.then (replies) ->
						status.replies = replies
						callback status

	function get-stargazers(status, callback)
		status-get-stargazers status .then (stargazers) ->
			| !stargazers? => callback status
			| _ =>
				status.stargazers = stargazers
				callback status

	if status.to-object
		status .= to-object!
	status.display-created-at = moment status.created-at .format 'YYYY年M月D日 H時m分s秒'
	status <- serialyze-repost status
	status.is-reply = status.in-reply-to-status-id?
	status <- get-app status
	status <- get-user status
	status <- get-reply-source status
	status <- get-replies yes status
	status <- get-stargazers status
	if me?
		status.is-favorited <- status-check-favorited me.id, status.id .then
		status.is-reposted <- status-check-reposted me.id, status.id .then
		callback status
	else
		status.is-favorited = null
		status.is-reposted = null
		callback status
