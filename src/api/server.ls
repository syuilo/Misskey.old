require! {
	express
	cookie
	multer
	redis
	body-parser
	cookie-parser
	'express-session': session
	'js-yaml': yaml
	'../config': config
	'./router': router
}

RedisStore = (require 'connect-redis') session

api-server = express!
	..disable 'x-powered-by'

server = (require \http).Server api-server
	..listen config.port.api

session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

api-server
	..use body-parser.urlencoded extended: true
	..use multer!
	..use cookie-parser config.cookie_pass
	..use session do
		key: config.session-key
		secret: config.session-secret
		resave: false
		save-uninitialized: true
		cookie:
			path: '/'
			domain: '.' + config.public-config.domain
			http-only: false
			secure: false
			max-age: null
		store: session-store

api-server.use (req, res, next) ->
	sent = (data) -> switch req.format
		| 'json' => res.json data
		| 'yaml' =>
			res
				..header 'Content-Type' 'text/x-yaml'
				..send yaml.safe-dump data
		| _ => res.json data
	
	res.api-render = (data) -> sent data

	res.api-error = (code, message) ->
		res.status code
		sent do
			error:
				message: message
	next!

api-server.all '*' (req, res, next) ->
	res.set do
		'Access-Control-Allow-Origin': config.public-config.url
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
		'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
		'Access-Control-Allow-Credentials': true
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

require './streaming-server'
