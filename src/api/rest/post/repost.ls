required! {
	'../../../models/notice': Notice
	'../../../models/post': Post
	'../../../utils/steaming': Streamer
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
}

authorize = require '../../auth'

repost-step = (req, res, app, user, target-post) ->
	Post.is-reposted target-post.id, user.id, (is-reposted) ->
		if is-reposted
			res.api-error 400 'This post is already reposted :)'
			return
		User.find target-post.user-id, (target-post-user) ->
			Post.create target-post.user-id, (target-post-user) ->
				Post.create app.id, null, null, 'RP @' + target-post-user.screen-name + ' ' + target-post.text, user.id, target-post.id, (post) ->
					target-post.reposts-count++
					target-post.update ->
					Post.build-response-object target-post, (target-post-obj) ->
						target-post-obj.is-repost-to-post = true
						target-post-obj.repostedByUser = user.filt!
						res.api-render target-post-obj
						stream-obj = JSON.stringify do
							type: 'repost'
							value: target-post-obj
						Streamer.publish 'userStream:' + user.id, stream-obj
						UserFollowing.find-by-followee-id user.id, (user-followings) ->
							if user-followings != null
								user-followings.for-each (user-following) ->
									Streamer.publish 'userStream:' + user-following.follower-id, stream-obj
					content = {}
					content.post = post
					content.user = user.filt!
					Notice.create config.web-client-id, 'repost', JSON.stringify content, target-post-user.id, (notice) ->
						Streamer.publish 'userStream:' + target-post-user.id, JSON.stringify do
							type: 'notice'
							value: notice


module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		if req.body.post_id == null
			res.api-error 400 'post_id parameter is required :('
			return
		post-id = req.body.post-id

		Post.find post-id, (target-post) ->
			if target-post == null
				res.api-error 404 'Post not found...'
				return
			if target-post.user-id == user.id
				res.api-error 400 'This post is your post!!!'
				return
			if target-post.repost-from-post-id == null
				repost-step req, res, app, user, target-post
			else
				Post.find target-post.repost-from-post-id (true-target-post) ->
					repost-step req, res, app, user, true-target-post
