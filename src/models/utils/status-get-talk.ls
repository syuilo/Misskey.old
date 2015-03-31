require! {
	async
	'../user': User
	'../status': Status
	'./status-get-before-talk'
}

module.exports = (status, callback) ->
	status-get-before-talk status.in-reply-to-status-id .then (talk) ->
		async.map do
			talk
			(talk-status, next) ->
				talk-status.is-reply = talk-status.in-reply-to-status-id?
				User.find-by-id talk-status.user-id, (, talk-status-user) ->
					talk-status.user = talk-status-user
					next null, talk-status
			(, talk-statuses) ->
				callback talk-statuses
