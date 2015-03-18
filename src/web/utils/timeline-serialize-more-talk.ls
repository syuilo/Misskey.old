require! {
	async
	'../../models/user': User
	'../../models/status': Status
}

exports = (status, callback) ->
	Status.get-before-talk status.in-reply-to-status-id, (talk) ->
		async.map do
			talk
			(talk-status, next) ->
				talk-status.is-reply = talk-status.in-reply-to-status-id != 0 && talk-status.in-reply-to-status-id != null
				User.find talk-status.user-id, (talk-status-user) ->
					talk-status.user = talk-status-user
					next null, talk-status
			(err: any, talk-statuses) ->
				callback talk-statuses
