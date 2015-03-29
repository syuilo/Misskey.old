require! {
	cookie
	redis
	'../../models/user': User
	'../../web/utils/timeline-serialyzer'
	'../../web/utils/parse-text'
	'../../config'
}
module.exports = (io, session-store) ->
	socket <- io.of '/streaming/web/home' .on \connection
	cookies = cookie.parse socket.handshake.headers.cookie
	sid = cookies[config.session-key]
	sidkey = sid.match /s:(.+?)\./ .1
	err, session <- session-store.get sidkey
	switch
	| err => console.log err.message
	| !session? => console.log "undefined: ${sidkey}"
	| _ =>
		uid = socket.user-id = session.user-id
		err, user <- User.find-by-id uid
		socket.user = user
		pubsub = redis.create-client!
			..subscribe "misskey:userStream:#{uid}"
			..on \message (, content) ->
			try
				content = parse-json content
				if content.type? && content.value?
					switch content.type
					| \status =>
						status-compiler = jade.compile-file "#__dirname/../../web/views/templates/status/status.jade"
						timeline-serialyzer content.value, socket.user, (timeline-status) ->
							html = status-compiler do
								status: timeline-status
								login: yes
								text-parser: parse-text
								config: config.public-config
							socket.emit content.type, html
					| _ => socket.emit content.type, content.value
				else
					socket.emit content
			catch e
				socket.emit content
		socket.on \disconnect ->
