require! {
	fs
	cookie
	redis
	jade
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-post': BBSPost
	'../../web/main/utils/bbs-post-serialyzer'
	'../../config'
	'express-session': session
}

module.exports = (io, session-store) ->
	# Listen connect event
	socket <- io.of '/streaming/web/bbs-thread' .on \connection

	# Get cookies
	cookies = cookie.parse socket.handshake.headers.cookie

	# Get sesson key
	sid = cookies[config.session-key]
	sidkey = sid.match /s:(.+?)\./ .1

	# Resolve session
	err, session <- session-store.get sidkey
	switch
	| err? => console.log err.message
	| !session? => console.log "undefined: #sidkey"
	| _ =>
		uid = socket.user-id = session.user-id

		# Get session user
		err, user <- User.find-by-id uid
		socket.user = user

		publisher = redis.create-client!

		socket
			..emit \connected
			..on \init (req) ->
				# Get session user
				thread-id = req\thread-id
				socket.thread-id = thread-id
				err, thread <- BBSThread.find-by-id thread-id
				socket.thread = thread

				subscriber = redis.create-client!
					..subscribe "misskey:bbsThreadStream:#{thread-id}"

				socket.emit \inited
				subscriber.on \message (channel, content) ->
					try
						content = parse-json content
						if content.type? && content.value?
							switch content.type
							| \post =>
								# Find post
								err, post <- BBSPost.find-by-id content.value.id
								# Send HTML
								post-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/bbs-post/post.jade"
								bbs-post-serialyzer post, (serialized-post) ->
									socket.emit content.type, post-compiler do
										post: serialized-post
										config: config.public-config
							| _ => socket.emit content.type, content.value
						else
							socket.emit content
					catch e
						socket.emit content
