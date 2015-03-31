require! {
	'../application': Application
	'../user': User
	'../status': Status
	'./status-get-talk': serialize-talk
	'../../config'
}

module.exports = (status, callback) ->
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
	
	function get-reply(status, callback)
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
					status.reply = reply-status
					User.find-by-id reply-status.user-id, (, reply-user) ->
						reply-user .= to-object!
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
			Status.find-by-id status.repost-from-status-id, (, repost-from-status) ->
				| repost-from-status? =>
					_repost-from-status = repost-from-status
						..is-repost-to-status = yes
						..source = status
					User.find-by-id status.user-id, (, reposted-by-user) ->
						_repost-from-status.reposted-by-user = reposted-by-user
						callback _repost-from-status
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
	callback status
	