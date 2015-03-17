require! {
	fs
	https
	cookie
	redis
	'../config': config
	'./socketio/home': home
	'./socketio/talk': talk
	'express-session': session
	'socket.io': SocketIO
}

server = https.create-server do
	key: (fs.read-file-sync '../../../../certs/server.key').to-string!
	cert: (fs.read-file-sync '../../../../certs/startssl.crt').to-string!
	ca: (fs.read-file-sync '../../../../certs/sub.class1.server.ca.pem').to-string!
	
	(req, res) ->
		res
			..write-head 200 'Content-Type': 'text/plain'
			..end 'kyoppie'
	
server.listen config.port.streaming

io = SocketIO.listen server, origins: 'misskey.xyz:*'

RedisStore = (require \connect-redis) session
session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

# Authorization
io.use (socket, next) ->
	handshake = socket.request
	cookies = cookie.parse handshake.headers.cookie
	switch
	| handshake == null => fallthrough
	| !handshake.headers.cookie? => fallthrough
	| !cookies[config.session-key]? => fallthrough
	| !(cookies[config.session-key].match /s:(.+?)\./) => next new Error '[[error:not-authorized]]'
	| _ => next!

# Home stream
home io, session-store

# Talk stream
talk io, session-store
