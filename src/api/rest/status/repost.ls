require! {
	'../../auth': authorize
	'../../internal/create-status'
	'../../../utils/get-express-params'
	'../../../models/status': Status
	'../../../models/utils/status-check-reposted'
	'../../../models/user': User
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[status-id, text] = get-express-params req, <[ status-id text ]>
	switch
	| empty status-id => res.api-error 400 'status-id parameter is required :('
	| _ => Status.find-by-id status-id, (, target-status) ->
		| !target-status? => res.api-error 404 'Post not found...'
		| target-status.user-id.to-string! == user.id => res.api-error 400 'This post is your post!!!'
		| target-status.repost-from-status-id? => # Repostなら対象をRepost元に差し替え
			Status.find-by-id target-status.repost-from-status-id, (, true-target-status) ->
				repost-step true-target-status
		| _ => repost-step target-status

	function repost-step(target-status) -> status-check-reposted user.id, target-status.id .then (is-reposted) ->
		| is-reposted => res.api-error 400 'This post is already reposted :)'
		| _ => User.find-by-id target-status.user-id, (, target-status-user) ->
			image = null
			path = null
			if (Object.keys req.files).length == 1 =>
				path = req.files.image.path
				image = fs.read-file-sync path

			create-status do
				app, user, text, null, image, target-status
			.then do
				(status) ->
					if path? then fs.unlink path
					if status?
						res.api-render status.to-object!
					else
						res.api-render \ok
				(err) ->
					if path? then fs.unlink path
					res.api-error 400 err