require! {
	cookie
	redis
	jade
	'../../models/user': User
	'../../models/status': Status
	'../../web/utils/serialize-timeline-status'
	'../../web/utils/parse-text'
	'../../config'
}
module.exports = (io, session-store) ->
	# Listen connect event
	socket <- io.of '/streaming/web/home' .on \connection
	
	# Get cookies
	cookies = cookie.parse socket.handshake.headers.cookie
	
	# Get sesson key
	sid = cookies[config.session-key]
	sidkey = sid.match /s:(.+?)\./ .1
	
	# Resolve session
	err, session <- session-store.get sidkey
	switch
	| err => console.log err.message
	| !session? => console.log "undefined: #{sidkey}"
	| _ =>
		# Set user id
		socket.user-id = session.user-id
		
		# Get and set session user
		err, user <- User.find-by-id socket.user-id
		socket.user = user
		
		# Subscribe Home stream channel
		pubsub = redis.create-client!
			..subscribe "misskey:userStream:#{uid}"
			..on \message (, content) ->
				try
					content = parse-json content
					if content.type? && content.value?
						switch content.type
							| \status, \repost =>
								# Find status
								err, status <- Status.find-by-id content.value.id
								# Send timeline status HTML
								status-compiler = jade.compile-file "#__dirname/../../web/views/templates/status/status.jade"
								serialize-timeline-status status, socket.user, (serialized-status) ->
									socket.emit content.type, status-compiler do
										status: serialized-status
										login: yes
										me: socket.user
										text-parser: parse-text
										config: config.public-config
							| _ => socket.emit content.type, content.value
					else
						socket.emit content
				catch e
					socket.emit content

		# Disconnect event
		socket.on \disconnect ->
