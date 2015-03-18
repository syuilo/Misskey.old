require! {
	cookie
	redis
	'../../config': config
}
module.exports = (io, session-store) ->
	io.of '/streaming/home' .on \connection (socket) ->
		cookies = cookie.parse socket.handshake.headers.cookie
		sid = cookies[config.session-key]
		sidkey = sid.match /s:(.+?)\./ .1
		session-store.get sidkey, (err, session) ->
			if err
				console.log err.message
			else
				if session == null
					console.log 'undefined: ' + sidkey
				else
					uid = socket.user-id = session.user-id
					pubsub = redis.create-client!
						..subscribe 'misskey:userStream:' + uid
						..on \message (channel, content) ->
						try
							content = JSON.parse content
							if content.type != null && content.value != null
								then socket.emit content.type, content.value
								else socket.emit content
						catch e
							socket.emit content
					socket.on \disconnect ->
