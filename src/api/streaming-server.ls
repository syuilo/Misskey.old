require! {
	fs
	https
	cookie
	redis
	'../config'
	'./streaming/home'
	'./streaming/talk'
	'express-session': session
	'socket.io': SocketIO
}

read-file = (path) -> fs.read-file-sync path .to-string!

server = https.create-server do
	key: read-file '../../../../certs/server.key'
	cert: read-file '../../../../certs/startssl.crt'
	ca: read-file '../../../../certs/sub.class1.server.ca.pem'

	(req, res) ->
		res
			..write-head 200 'Content-Type': 'text/plain'
			..end 'kyoppie'

server.listen config.port.streaming

io = SocketIO.listen server, origins: "#{config.public-config.domain}:*"

RedisStore = (require \connect-redis) session
session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

# Authorization
io.use (socket, next) ->
	handshake = socket.request
	cookies = cookie.parse handshake.headers.cookie
	switch
	| !handshake? => fallthrough
	| !handshake.headers.cookie? => fallthrough
	| !cookies[config.session-key]? => fallthrough
	| cookies[config.session-key] != /s:(.+?)\./ => next new Error '[[error:not-authorized]]'
	| _ => next!

# Home stream
home io, session-store

# Talk stream
talk io, session-store
