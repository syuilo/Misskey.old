require! {
	fs
	gm
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../utils/register-image'
}

module.exports = (app, user, thread-id, title, image = null) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	title .= trim!
	(err, thread) <- BBSThread.find-by-id thread-id
	switch
	| !thread? => throw-error \thread-not-found 'Thread not found.'
	| thread.user-id.to-string! != user.id.to-string! => throw-error \access-denied 'Access denied.'
	| _ =>
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

	function update(image)
		if image?
			register-image user, \bbs-thread-eyecatch "#{thread.id}.jpg", \jpg, image .then (path) ->
				thread.eyecatch-image = path
				thread.save ->
					resolve thread
		else
			resolve thread