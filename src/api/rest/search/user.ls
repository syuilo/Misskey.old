require! {
	'../../../models/user': User
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| !(query = req.query.query)? => res.api-error 400 'query parameter is required!!'
	| _ =>
		reg = new RegExp query, \i
		db-query =
			if query == /^[a-zA-Z0-9_]+$/
			then {screen-name: reg}
			else {name: reg}
		User.find db-query
		.sort {followers-count: -1}
		.limit 5users
		.exec (err, users) ->
			users |> each (user) ->
				user .= to-object!
			res.api-render users