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
	'./router': router
	'../utils/publish-redis-streaming'
	'../utils/convert-string-to-color'
	'../config'
}

# Init session store
RedisStore = connect-redis session

# Create server
api-server = express!
	..disable 'x-powered-by'

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

api-server.use (req, res, next) ->
	res.api-render = (data) ->
		switch req.format
		| \json => res.json data
		| \yaml =>
			res
				..header 'Content-Type' 'text/x-yaml'
				..send yaml.safe-dump data
		| \plain =>
			res
				..header 'Content-Type' 'text/plain'
				..send data
		| _ => res.json data
	res.api-error = (http-status-code, error) ->
		res.status http-status-code
		res.api-render {error}
	next!

# CORS middleware
#
# see: http://stackoverflow.com/questions/7067966/how-to-allow-cors-in-express-nodejs
allow-cross-domain = (req, res, next) ->
	res
		..header 'Access-Control-Allow-Credentials' yes
		..header 'Access-Control-Allow-Origin' 'https://misskey.xyz https://misskey.xyz:1206 http://dev.misskey.xyz http://dev.misskey.xyz:1205'
		..header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE'
		..header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept'

    # intercept OPTIONS method
	if req.method == \OPTIONS
		res.send 204
	else
		next!

# CORS
api-server.use allow-cross-domain

# Log
api-server.all '*' (req, res, next) ->
	next!
	ua = req.headers['user-agent'].to-lower-case!
	publish-redis-streaming \log to-json {
		type: \api
		value:
			date: Date.now!
			remote-addr: req.ip
			protocol: req.protocol
			method: req.method
			path: req.path
			ua: ua
			color: convert-string-to-color req.ip
			done: yes
	}

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

require './web-streaming-server'

exports.server = api-server