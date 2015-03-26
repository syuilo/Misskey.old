require! {
	'../../../models/status': Status
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/utils/status-check-reposted'
	'../../../models/utils/status-response-filter'
	'../../../models/utils/filter-user-for-response'
	'../../../utils/publish-redis-streaming'
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	| (status-id = req.body.status_id) == null => res.api-error 400 'status_id parameter is required :('
	| _ => Status.find-by-id status-id, (, target-status) ->
		| target-status? => res.api-error 404 'Post not found...'
		| target-status.user-id == user.id => res.api-error 400 'This post is your post!!!'
		| target-status.repost-from-status-id? => # Repostなら対象をRepost元に差し替え
			Status.find-by-id target-status.repost-from-status-id (true-target-status) ->
				repost-step req, res, app, user, true-target-status
		| _ => repost-step req, res, app, user, target-status

repost-step = (req, res, app, user, target-status) -> status-check-reposted user.id, target-status.id, (is-reposted) ->
	| is-reposted => res.api-error 400 'This post is already reposted :)'
	| _ => User.find-by-id target-status.user-id, (, target-status-user) ->
		Status.insert do
			app-id: app.id
			text: "RP @#{target-post-user.screen-name} #{target-post.text}"
			user-id: user.id
			repost-from-status-id: target-post.id
			(, status) ->
				target-status
					..reposts-count++
					..save (err) ->
				status-response-filter target-status, (target-status-obj) ->
					target-status-obj
						..is-repost-to-status = true
						..reposted-by-user = filter-user-for-response user
						.. |> res.api-render

					stream-obj = to-json do
						type: \repost
						value: target-status-obj
					publish-redis-streaming 'userStream:' + user.id, stream-obj
					UserFollowing.find { followee-id: user.id } (, user-followings) ->
						| user-followings? => user-followings.for-each (user-following) ->
							publish-redis-streaming 'userStream:' + user-following.follower-id, stream-obj
