require! {
	fs
	cookie
	redis
	jade
	'../../models/user': User
	'../../models/talk-message': TalkMessage
	'../../web/utils/serialize-talk-message'
	'../../web/utils/parse-text'
	'../../config'
	'express-session': session
}
module.exports = (io, session-store) ->
	# Listen connect event
	socket <- io.of '/streaming/talk' .on \connection

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
				otherparty-id = req\otherparty-id
				socket.otherparty-id = otherparty-id
				err, otherparty <- User.find-by-id otherparty-id
				socket.otherparty = otherparty

				subscriber = redis.create-client!
					..subscribe "misskey:talkStream:#{uid}-#{socket.otherparty-id}"
				publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}" \otherparty-enter-the-talk

				socket.emit \inited
				subscriber.on \message (channel, content) ->
					try
						content = parse-json content
						if content.type? && content.value?
							switch content.type
							| \me-message, \otherparty-message =>
								# Find message
								err, message <- TalkMessage.find-by-id content.value.id
								# Send message HTML
								message-compiler = jade.compile-file "#__dirname/../../web/views/templates/user-talk/message.jade"
								serialize-talk-message message, socket.user, socket.otherparty .then (serialized-message) ->
									socket.emit content.type, message-compiler do
										message: serialized-message
										me: socket.user
										text-parser: parse-text
										config: config.public-config
							| _ => socket.emit content.type, content.value
						else
							socket.emit content
					catch e
						socket.emit content
			..on \read (id) ->
				publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}" to-json do
					type: \read
					value: id
			..on \alive (req) ->
				publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}" \alive
			..on \type (text) ->
				publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}" to-json do
					type: \type
					value: text
			..on \disconnect ->
				publisher.publish "misskey:talkStream:#{socket.otherparty-id}-#{uid}" \otherparty-left-the-talk
