require! {
	moment
	'../../models/application': Application
	'../../models/user': User
	'../../models/status': Status
	'../../models/utils/status-get-talk'
	'../../models/utils/status-get-replies'
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'../../config'
}

module.exports = (status, me, callback) ->
	function serialyze-repost(status, callback)
		switch
		| status.repost-from-status-id? =>
			Status.find-by-id status.repost-from-status-id, (, repost-from-status) ->
				| repost-from-status? =>
					User.find-by-id repost-from-status.user-id, (, reposted-from-user) ->
						repost-from-status .= to-object!
						reposted-from-user .= to-object!
						repost-from-status.user = reposted-from-user
						status.repost-source = repost-from-status
						callback status
				| _ =>
					status.is-repost-to-status = no
					callback status
		| _ =>
			status.is-repost-to-status = no
			callback status

	function get-app(status, callback)
		if status.app-id?
			Application.find-by-id status.app-id, (, app) ->
				status.app = {
					name: app.name
					description: app.description
					icon-image-url: app.icon-image-url
					screen-id: app.screen-id
				}
				callback status
		else
			status.app = null
			callback status

	function get-user(status, callback)
		User.find-by-id status.user-id, (, user) ->
			status.user = user.to-object!
			delete status.user.icon-image
			delete status.user.banner-image
			delete status.user.wallpaper-image
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
						if reply-status.is-reply
							status-get-talk reply-status .then (talk) ->
								status.more-talk = talk
								callback status
						else
							callback status

	function get-replies(status, callback)
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
								resolve reply
						else
							resolve null)
					.then (replies) ->
						status.replies = replies
						callback status

	status .= to-object!
	status.display-created-at = moment status.created-at .format 'YYYY年M月D日 H時m分s秒'
	status <- serialyze-repost status
	status.is-reply = status.in-reply-to-status-id?
	status <- get-app status
	status <- get-user status
	status <- get-reply-source status
	status <- get-replies status
	if me?
		status.is-favorited <- status-check-favorited me.id, status.id .then
		status.is-reposted <- status-check-reposted me.id, status.id .then
		callback status
	else
		status.is-favorited = null
		status.is-reposted = null
		callback status
	
