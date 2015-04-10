require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../utils/publish-redis-streaming'
	'../../../models/utils/filter-user-for-response'
	'../../../models/utils/serialize-status'
	'../../../models/status': Status
	'../../../models/utils/status-check-reposted'
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
}

module.exports = (req, res) -> authorize req, res, (user, app) -> 
	[status-id] = get-express-params req, <[ status-id ]>
	switch
	| empty status-id => res.api-error 400 'status-id parameter is required :('
	| _ => Status.find-by-id status-id, (, target-status) ->
		| !target-status? => res.api-error 404 'Post not found...'
		| target-status.user-id.to-string! == user.id => res.api-error 400 'This post is your post!!!'
		| target-status.repost-from-status-id? => # Repostなら対象をRepost元に差し替え
			Status.find-by-id target-status.repost-from-status-id, (, true-target-status) ->
				repost-step req, res, app, user, true-target-status
		| _ => repost-step req, res, app, user, target-status

repost-step = (req, res, app, user, target-status) -> status-check-reposted user.id, target-status.id .then (is-reposted) ->
	| is-reposted => res.api-error 400 'This post is already reposted :)'
	| _ => User.find-by-id target-status.user-id, (, target-status-user) ->
		status = new Status do
			app-id: app.id
			text: "RP @#{target-status-user.screen-name} #{target-status.text}"
			user-id: user.id
			repost-from-status-id: target-status.id
		status.save (, created-status) ->
			target-status
				..reposts-count++
				..save (err) ->
					serialize-status target-status, (target-status-obj) ->
						target-status-obj
							..is-repost-to-status = true
							..reposted-by-user = filter-user-for-response user
							.. |> res.api-render
						stream-obj = to-json do
							type: \repost
							value: { id: created-status.id }
						publish-redis-streaming "userStream:#{user.id}", stream-obj
						UserFollowing.find { followee-id: user.id } (, user-followings) ->
							| !empty user-followings => user-followings |> each (user-following) ->
								publish-redis-streaming "userStream:#{user-following.follower-id}", stream-obj
