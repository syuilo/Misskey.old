require! {
	'../user': User
	'../status': Status
	'./status-get-before-talk'
}

# Status -> Promise [Status]
module.exports = (status) ->
	talk <- status-get-before-talk status.in-reply-to-status-id .then
	Promise.all (talk |> map (talk-status) ->
		new Promise (resolve, reject) ->
			talk-status.is-reply = talk-status.in-reply-to-status-id?
			User.find-by-id talk-status.user-id, (, talk-status-user) ->
				talk-status.user = talk-status-user
				resolve talk-status)
