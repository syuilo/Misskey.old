require! {
	async
	'../../api-response': APIResponse
	'../../../models/application': Application
	'../../../models/User': User
	'../../../utils/streaming': Streamer
}

authorize = require '../../auth'

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.query.query == null
			res.apiError 400, 'query parameter is required :('
			return
		query = req.query.query
		if query == ''
			res.apiError 400, 'Empty query'
			return
		query = query.replace /^@/, '';
		User.searchByScreenName query, 5, (users) ->
			async.map users, (user, next) ->
				next null, user.filt!
			, (err, results) ->
				res.apiRender results;
