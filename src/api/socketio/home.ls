require! {
	cookie
	redis
	'../../models/user': User
	'../../web/utils/status-serialyzer'
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
		uid = socket.user-id = session.user-id
		
		# Get session user
		err, user <- User.find-by-id uid
		socket.user = user
		
		# Subscribe Home stream channel
		pubsub = redis.create-client!
			..subscribe "misskey:userStream:#{uid}"
			..on \message (, content) ->
				try
					content = parse-json content
					console.log content.value
					console.log socket.user
					if content.type? && content.value?
						socket.emit content.type, switch content.type
						| \status =>
							# Send timeline status HTML
							status-compiler = jade.compile-file "#__dirname/../../web/views/templates/status/status.jade"
							status-serialyzer content.value, socket.user, (serialized-status) ->
								console.log serialized-status
								status-compiler do
									status: serialized-status
									login: yes
									text-parser: parse-text
									config: config.public-config
						| _ => content.value
					else
						socket.emit content
				catch e
					socket.emit content

		# Disconnect event
		socket.on \disconnect ->
