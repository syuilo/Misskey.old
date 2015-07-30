require! {
	'../../../models/user': User
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(query = req.query.query)? => res.api-error 400 'query parameter is required!!'
	| _ =>
		search-type = null
		if query == /^@?[a-zA-Z0-9_]+$/
			reg = new RegExp (query.replace \@ ''), \i
			db-query = {screen-name: reg}
			search-type = \screen-name
		else
			reg = new RegExp query, \i
			db-query = {name: reg}
			search-type = \name
		User.find db-query
		.sort {followers-count: -1}
		.limit 5users
		.exec (err, users) ->
			users |> each (user) ->
				user .= to-object!
			if (search-type == \screen-name) and (users.length < 5users)
				reg = new RegExp query, \i
				User.find {name: reg}
				.sort {followers-count: -1}
				.limit 5users - users.length
				.exec (err, other-users) ->
					other-users |> each (user) ->
						user .= to-object!
					res.api-render users.concat other-users
			else
				res.api-render users