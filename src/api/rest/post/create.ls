require! {
	async
	fs
	gm
	'../../../models/post': Post
	'../../../models/post-image': PostImage
	'../../../models/post-mention': PostMention
	'../../../utils/streaming': Streamer
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
}

authorize = require '../../auth'

module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		Post.find-by-user-id user.id, 1, null, null, (post) ->
			text = req.body.text != null ? req.body.text : ''
			in-reply-to-post-id = req.body.in_reply_to_post_id != null ? req.body.in_reply_to_post_id : null

			text = text.trim!

			if posts != null && text === posts[0].text
				res.api-error 400 'duplicate content :('
				return

			if (Object.keys req.files).length === 1
				path = req.files.image.path
				image-quality = user.is-premium ? 90 : 70
				gm path
					.compress 'jpeg'
					.quality image-quality
					.to-buffer 'jpeg', (error, buffer) ->
						if error
							throw error
						fs.unlink path
						create req, res, app.id, in-reply-to-post-id, buffer, true, next, text, user.id
			else
				create req, res, app.id, in-reply-to-post-id, null, false, text, user.id

create = (req, res, app-id, irtpi, image, is-image-attached, text, user-id) ->
	Post.create app-id, irtpi, is-image-attached, text, user-id, null, (post) ->
		if is-image-attached
			PostImage.create post.id, image, (post-image) ->
				send-response!
		else
			send-response!

	send-response = ->
		Post.build-response-object post, (obj) ->
			if obj.reply != null
				if obj.reply.is-reply
					get-more-talk obj.reply, (talk) ->
						obj.more-talk = talk
						send obj
				else
					send obj
			else
				send obj

	send = (obj) ->
		res.api-render obj

		stream-obj = JSON.stringify do
			type: 'post'
			value: obj

		Streamer.publish 'userStream:' + user-id, stream-obj

		UserFollowing.find-by-followee-id user-id, (user-followings) ->
			if user-followings != null
				user-followings.for-each (user-following) ->
					Streamer.publish 'userStream:' + user-following.follower-id, stream-obj

		mentions = obj.text.match /@[a-zA-Z0-9_]+/g
		if mentions != null
			mentions.for-each (mention-sn) ->
				mention-sn = mention-sn.replace '@', ''
				User.find-by-screen-name mention-sn, (reply-user) ->
					if reply-user != null
						PostMention.create obj.id, reply-user.id, (created-mention) ->
							stream-mention-obj = JSON.stringify do
								type: 'reply'
								value: obj
							Streamer.publish 'userStream:' + reply-user.id, stream-mention-obj

	get-more-talk = (post, callback) ->
		Post.get-before-talk post.in-reply-to-post-id, (more-talk) ->
			async.map more-talk, (talk-post, map-next) ->
				talk-post.is-reply = talk-post-in-reply-to-post-id != 0 && talk-post.in-reply-to-post-id != null
				User.find talk-post.user-id, (talk-post-user) ->
					talk-post.user = talk-post-user
					map-next null, talk-post
			, (err, more-talk-posts) ->
				callback more-talk-posts
