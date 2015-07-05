require! {
	fs
	https
	cookie
	redis
	'../config'
	'./streaming/home'
	'./streaming/talk'
	'./streaming/bbs-thread'
	'./streaming/log'
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

server.listen config.port.web-streaming

io = SocketIO.listen server, origins: "#{config.public-config.domain}:*"

RedisStore = (require \connect-redis) session
session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

# Authorization
io.use (socket, next) ->
	raw-cookie = socket?request?headers?cookie
	if cookie
		parsed-cookie = cookie.parse raw-cookie
		is-authorized = parsed-cookie[config.session-key] != /s:(.+?)\./
		if is-authorized
		then next new Error '[[error:not-authorized]]'
		else next!

# Home stream
home io, session-store

# Talk stream
talk io, session-store

# BBS Thread stream
bbs-thread io, session-store

# Misskey log stream
log io
