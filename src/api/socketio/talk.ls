require! {
	fs
	cookie
	redis
	'../../config'
	'express-session': session
}
module.exports = (io, session-store) ->
	io.of '/streaming/talk' .on \connection (socket) ->
		cookies = cookie.parse socket.handshake.headers.cookie
		sid = cookies[config.session-key]

		sidkey = sid.match /s:(.+?)\./ .1
		session-store.get sidkey, (err, session) ->
			if err
				console.log err.message
			else
				if !session?
					console.log "undefined: #sidkey"
				else
					uid = socket.user-id = session.user-id
					publisher = redis.create-client!
					socket
						..emit \connected
						..on \init (req) ->
							otherparty-id = String req.otherparty-id
							socket.otherparty-id = otherparty-id
							subscriber = redis.create-client!
								..subscribe "misskey:talkStream:#{uid}-#{socket.otherparty-id}"
							publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}", \otherpartyEnterTheTalk
							socket.emit \inited
							subscriber.on \message (channel, content) ->
								try
									content = parse-json content
									if content.type? && content.value?
										then socket.emit content.type, content.value
										else socket.emit content
								catch e
									socket.emit content
						..on \read (id) ->
							publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}", to-json do
								type: \read
								value: id
						..on \alive (req) ->
							publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}", \alive
						..on \type (text) ->
							publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}", to-json do
								type: \type
								value: text
						.on \disconnect ->
						publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}", \otherpartyLeftTheTalk
