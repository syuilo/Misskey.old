require! {
	'../../../models/user': User
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(query = req.query.query)? => res.api-error 400 'query parameter is required!!'
	| _ =>
		if query == /^@?[a-zA-Z0-9_]+$/
			reg = new RegExp (query.replace \@ ''), \i
			db-query = {screen-name: reg}
		else
			reg = new RegExp query, \i
			db-query = {name: reg}
		User.find db-query
		.sort {followers-count: -1}
		.limit 5users
		.exec (err, users) ->
			users |> each (user) ->
				user .= to-object!
			res.api-render users