require! {
	fs
	gm
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-thread-eyecatch': BBSThreadEyecatch
}

module.exports = (app, user, thread-id, title, image = null) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	title .= trim!
	(err, thread) <- BBSThread.find-by-id thread-id
	if thread?
		if image?
			image-quality = if user.is-plus then 80 else 60
			gm image
				.compress \jpeg
				.quality image-quality
				.to-buffer \jpeg (err, buffer) ->
					if err? || !buffer?
						throw-error \failed-attach-image 'Failed attach image.'
					else
						update buffer
		else
			update null
	else
		throw-error \thread-not-found 'Thread not found.'

	function update(image)
		if image?
			(, eyecatch) <- BBSThreadEyecatch.find-one {thread-id}
			if eyecatch?
				eyecatch.image = image
				eyecatch.save ->
					resolve thread
			else
				new-eyecatch = new BBSThreadEyecatch {thread-id, image}
				new-eyecatch.save ->
					resolve thread
		else
			resolve thread