#
# Misskey API server
#

require! {
	express
	cookie
	multer
	redis
	'body-parser'
	'cookie-parser'
	'express-session': session
	'connect-redis'
	'js-yaml': yaml
	'oauth2-server'
	'socket.io': SocketIO
	'./router': router
	'./streaming/home'
	'./streaming/talk'
	'../models/oauth/oauth': oauth-model
	'../config'
}

# Init session store
RedisStore = connect-redis session

# Create server
api-server = express!
	..disable 'x-powered-by'

server = (require \http).Server api-server
	..listen config.port.api

session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

api-server
	..use body-parser.urlencoded {+extended}
	..use multer!
	..use cookie-parser config.cookie-pass
	..use session do
		key: config.session-key
		secret: config.session-secret
		resave: no
		save-uninitialized: yes
		cookie:
			path: '/'
			domain: ".#{config.public-config.domain}"
			http-only: no
			secure: no
			max-age: null
		store: session-store

# OAuth2 settings
api-server.oauth = oauth2-server do
	model: oauth-model
	grants: []
	debug: on
	access-token-lifetime: null

api-server.use (req, res, next) ->
	res.api-render = (data) ->
		switch req.format
		| \json => res.json data
		| \yaml =>
			res
				..header 'Content-Type' 'text/x-yaml'
				..send yaml.safe-dump data
		| _ => res.json data

	res.api-error = (code, message) ->
		res.status code
		res.api-render {error: {message}}
	next!

api-server.all '*' (req, res, next) ->
	res.set do
		'Access-Control-Allow-Origin': config.public-config.url
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
		'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
		'Access-Control-Allow-Credentials': yes
		'X-Frame-Options': \SAMEORIGIN
	next!

api-server.options '*' (req, res, next) ->
	res
		..set do
			'Access-Control-Allow-Headers': 'Origin, X-HTTP-Method-Override, X-Requested-With, Content-Type, Accept'
		..status 200
		..send!

router api-server

api-server.use (req, res, next) ->
	res.api-error 404 'API not found.'

# Init SocketIO
io = SocketIO.listen server, origins: "#{config.public-config.domain}:*"

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