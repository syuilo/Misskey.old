require! {
	'../user': User
	'../status': Status
}

# Status -> Promise Users
module.exports = (status, limit = 16users) ->
	resolve, reject <- new Promise!
	Status
		.find {repost-from-status-id: status.id}
		.sort {created-at: \desc}
		.limit 100posts
		.exec (, reposts) ->
			Promise.all (reposts |> map (repost) ->
				resolve, reject <- new Promise!
				User.find-by-id repost.user-id, (, repost-user) ->
					repost-user .= to-object!
					resolve repost-user)
			.then (users) ->
				resolve users