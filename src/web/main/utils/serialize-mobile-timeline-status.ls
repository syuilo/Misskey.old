require! {
	moment
	'../../../models/user': User
	'../../../models/status': Status
	'../../../models/utils/status-check-favorited'
	'../../../models/utils/status-check-reposted'
	'../../../config'
}

module.exports = (status, me, callback) ->
	serialize-status (serialized-status) ->
		if me?
			serialized-status.is-favorited <- status-check-favorited me.id, serialized-status.id .then
			serialized-status.is-reposted <- status-check-reposted me.id, serialized-status.id .then
			#serialized-status.is-favorited = no
			#serialized-status.is-reposted = no
			callback serialized-status
		else
			serialized-status.is-favorited = null
			serialized-status.is-reposted = null
			callback serialized-status

	function serialize-status(callback)
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
							if reply-status.is-reply
								status.is-talk = yes
							else
								status.is-talk = no
							callback status

		status .= to-object!
		status.display-created-at = moment status.created-at .format 'YYYY年M月D日 H時m分s秒'
		status <- serialyze-repost status
		status.is-reply = status.in-reply-to-status-id?
		status <- get-user status
		status <- get-reply-source status
		console.log status
		callback status
