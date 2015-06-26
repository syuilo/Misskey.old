require! {
	fs
	gm
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-post': BBSPost
	'../../models/bbs-post-image': BBSPostImage
	'../../utils/publish-redis-streaming'
}

module.exports = (app, user, thread-id, text, image = null) ->
	resolve, reject <- new Promise!
	text .= trim!
	switch
	| null-or-empty text => reject 'Empty text.'
	| null-or-empty thread-id => reject 'Empty thread-id.'
	| _ =>
		err, thread <- BBSThread.find-by-id thread-id
		if err?
			reject err
		else
			if thread?
				(err, recent-post) <- BBSPost.find-one {
					user-id: user.id
					thread-id: thread.id
				} .sort \-createdAt .exec 
				if err?
					reject err
				else
					switch
					| recent-post? && text == recent-post.text => reject 'Duplicate content.'
					| image? =>
						image-quality = if user.is-plus then 80 else 60
						gm image
							.compress \jpeg
							.quality image-quality
							.to-buffer \jpeg (, buffer) ->
								create app, user, thread, text, buffer
					| _ => create app, user, thread, text, null
			else
				reject 'Thread not found.'

function create(app, user, thread, text, image)
	err, count <- BBSPost.count {thread.id}
	if err?
		reject err
	else
		thread-cursor = count + 1

		post = new BBSPost!
			..app-id = app.id
			..text = text
			..user-id = user.id
			..thread-cursor = thread-cursor
			..thread-id = thread.id

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
		
		if err?
			reject err
		else
			switch
			| image? =>
				bbs-post-image = new BBSPostImage {post-id: created-post.id, image}
				bbs-post-image.save -> done!
			| _ => done!
