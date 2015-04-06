require! {
	async
	'../../models/status': Status
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'../../models/status-favorite': StatusFavorite
	'../../models/utils/status-get-before-talk'
	'../../models/user': User
}
module.exports = (req, res) ->
	async.series [
		(callback) -> 
			before-talks = status-get-before-talk req.root-post.id
			async.map before-talks, (before-talk, next) ->
				User.find-by-id before-talk.user-id, (, user) ->
					post.user = user
					next null user
			, (err, results) -> callback null results
		(callback) ->
			| req.login => callback null, status-check-favorited req.root-post.id, req.me.id
			| _ => callback null null
		(callback) ->
			| req.login => callback null, status-check-reposted req.root-post.id, req.me.id
			| _ => callback null null
	], (err, [before-talks, is-favorited, is-reposted]) ->
		post = req.root-post
		post.user = req.root-user
		res.display req, res, 'post' {post, before-talks, is-favorited, is-reposted}
