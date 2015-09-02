require! {
	'../user': User
	'../status': Status
	'../status-favorite': StatusFavorite
}

# Status -> Promise Users
module.exports = (status, limit = 16stargazers) ->
	new Promise (resolve, reject) ->
		StatusFavorite.find {status-id: status.id}
		.sort \-createdAt # Desc
		.limit limit
		.exec (err, stargazers) ->
			if stargazers?
				Promise.all (stargazers |> map (stargazer) ->
					new Promise (resolve, reject) ->
						User.find-by-id stargazer.user-id, (, user) ->
							resolve user)
					.then (users) ->
						resolve users
			else
				resolve null