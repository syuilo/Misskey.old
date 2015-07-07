require! {
	fs
	gm
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-thread-watch': BBSThreadWatch
	'../../models/bbs-post': BBSPost
	'../../models/bbs-post-image': BBSPostImage
	'../../models/utils/create-notice'
	'../../utils/publish-redis-streaming'
}

module.exports = (app, user, thread-id, text, image = null) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	text .= trim!
	switch
	| !image? && null-or-empty text => throw-error \empty-text 'Empty text.'
	| text.length > 1000chars => throw-error \too-long-text 'Too long text.'
	| null-or-empty thread-id => throw-error \empty-thread-id 'Empty thread-id.'
	| _ =>
		(err, thread) <- BBSThread.find-by-id thread-id
		if thread?
			(err, recent-post) <- BBSPost.find-one {user-id: user.id} `$and` {thread-id: thread.id} .sort \-createdAt .exec
			switch
			| recent-post? && text == recent-post.text => throw-error \duplicate-content 'Duplicate content.'
			| image? =>
				image-quality = if user.is-plus then 80 else 60
				gm image
					.compress \jpeg
					.quality image-quality
					.to-buffer \jpeg (err, buffer) ->
						if err? || !buffer?
							throw-error \failed-attach-image 'Failed attach image.'
						else
							create buffer
			| _ => create null
		else
			throw-error \thread-not-found 'Thread not found.'

		function create(image)
			err, count <- BBSPost.count {thread-id: thread.id}
			thread-cursor = count + 1

			post = new BBSPost!
				..app-id = if app? then app.id else null
				..text = text
				..user-id = user.id
				..thread-cursor = thread-cursor
				..thread-id = thread.id
				..is-image-attached = image?

			err, created-post <- post.save

			function done
				resolve created-post

				stream-obj = to-json do
					type: \post
					value: {id: post.id}

				publish-redis-streaming "bbsThreadStream:#{thread.id}" stream-obj

				mentions = text == />>[0-9]+/g
				if mentions?
					mentions |> each (mention-thread-cursor) ->
						mention-thread-cursor .= replace '>>' ''
						(, reply-post) <- BBSPost.find-one {thread-id: thread.id} `$and` {thread-cursor: mention-thread-cursor}
						if reply-post?
							stream-mention-obj = to-json do
								type: \thread-post-reply
								value: {post.id}
							publish-redis-streaming "userStream:#{reply-post.user-id}" stream-mention-obj
				
				(, watchers) <- BBSThreadWatch.find {thread-id: thread.id}
				watchers |> each (watcher) ->
					create-notice watcher.user-id, \bbs-thread-post {
						user-id: user.id
						thread-id: thread.id
						post-id: post.id
					} .then ->

			switch
			| err? => throw-error \post-save-error err
			| image? =>
				bbs-post-image = new BBSPostImage {post-id: created-post.id, image}
				bbs-post-image.save -> done!
			| _ => done!
