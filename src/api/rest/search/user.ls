require! {
	async
	'../../../models/user': User
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		query = req.query.query
		switch
			| query == null => res.api-error 400 'query parameter is required :('
			| query == '' => res.api-error 400 'Empty query'
			| _ =>
				query = query.replace /^@/ ''
				User.search-by-screen-name query, 5, (users) ->
					async.map users, (user, next) ->
						next null, user.filt!
					, (err, results) ->
						res.api-render results
