require! {
	cookie
	redis
	'../../config': config
}
exports = (io, session-store) ->
	socket <- io.of '/streaming/home' .on \connection
	cookies = cookie.parse socket.handshake.headers.cookie
	sid = cookies[config.session-key]
	sidkey = sid.match /s:(.+?)\./ .1
	(err, session) <- session-store.get sidkey
	switch
	| err => console.log err.message
	| !session? => console.log 'undefined: ' + sidkey
	| _ =>
		uid = socket.user-id = session.user-id
		pubsub = redis.create-client!
			..subscribe 'misskey:userStream:' + uid
			..on \message (channel, content) ->
			try
				content = JSON.parse content
				if content.type? && content.value?
					then socket.emit content.type, content.value
					else socket.emit content
			catch e
				socket.emit content
		socket.on \disconnect ->
