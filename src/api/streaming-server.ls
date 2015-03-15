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
		res.write-head 200 "Content-Type": "text/plain"
		res.end 'kyoppie'
	
server.listen 1207

io = SocketIO.listen server, origins: 'misskey.xyz:*'

RedisStore  (require \connect-redis) session
session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

/* Authorization */
io.use (socket, next) ->
	handshake = socket.request
	if handshake == null
		return next new Error '[[error:not-authorized]]'

	if handshake.headers.cookie != null
		cookies = cookie.parse handshake.headers.cookie
		if cookies[config.session-key] != null
			if cookies[config.session-key].match /s:(.+?)\./
				next!
			else
				return next new Error '[[error:not-authorized]]'
		else
			return next new Error '[[error:not-authorized]]'
	else
		return next new Error '[[error:not-authorized]]'

/* Home stream */
home io, session-store

/* Talk stream */
talk io, session-store
