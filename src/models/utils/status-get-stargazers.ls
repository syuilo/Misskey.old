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
		.exec (err, users) ->
			resolve users
