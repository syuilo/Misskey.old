require! {
	fs
	path
	async
	express
	'express-minify': minify
	'body-parser': body-parser
	'cookie-parser': cookie-parser
	'express-session': session
	'compression': compress
	'../models/application': Application
	'../models/user': User
	'../models/notice': Notice
	'../db': db
	'./routes/resources': resources-router
	'./routes/index': index-router
	'../config': config
}

RedisStore = (require 'connect-redis') session

cookie-expires = 1000ms * 60seconds * 60minutes * 24hours * 365days

web-server = express!
	..disable 'x-powered-by'
	..locals.compile-debug = false
	..set
		.. 'view engine' \jade
		.. 'views', __dirname + '/views'
	
	..use body-parser.urlencoded {+extended}
	..use cookie-parser config.cookie_pass

	# Session settings
	..use session do
		key: config.session-key
		secret: config.session-secret
		resave: false
		saveUninitialized: true
		cookie:
			path: '/'
			domain: '.' + config.public-config.domain
			http-only: false
			secure: false
			expires: new Date Date.now! + cookie-expires
			max-age: cookie-expires
		store: new RedisStore do
			db: 1
			prefix: 'misskey-session:'

	# Compressing settings
	..use
		.. compress!
		.. minify!

	..init-session = (req, res, callback) ->
		res.set do
			'Access-Control-Allow-Origin': config.public-config.url
			'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
			'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE'
			'Access-Control-Allow-Credentials': yes
			'X-Frame-Options': \SAMEORIGIN

		req
			..login = req.session != void && req.session != null && req.session.user-id != null # Is logged
			..data = # Render datas
				config: config
				url: config.public-config.url
				api-url: config.public-config.api-url
				login: req.login

		# Renderer function
		res.display = (req, res, name, render-data) -> res.render name, req.data <<< render-data

		if req.login
			user-id = req.session.user-id
			User.find user-id, (user) ->
				req
					..data.me = user
					..me = user
				callback!
		else
			req
				..data.me = null
				..me = null
			callback!

	# Statics
	..get '/favicon.ico' (req, res, next) ->
		res.sendFile path.resolve(__dirname + '/resources/favicon.ico')
	
	..get '/manifest.json', (req, res, next) ->
		res.send-file path.resolve(__dirname + '/resources/manifest.json')

# Resources rooting
resources-router web-server

# General rooting
web-server.all '*' (req, res, next) -> web-server.init-session req, res, -> next!

index-router web-server

# Not found handling
web-server.use (req, res, next) ->
	res
		..status 404
		..display req, res, 'notFound', {}

# Error handling
web-server.use (err, req, res, next) ->
	res.status 500
	if res.has-own-property 'display'
		res.display req, res, 'error', err: err
	else
		console.log err
		res.send!

# Listen
web-server.listen config.port.web
