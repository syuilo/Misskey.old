require! {
	fs
	path
	async
	express
	compression
	'../config'
	'body-parser'
	'cookie-parser'
	'connect-redis'
	'express-minify': minify
	'express-session': session
	'../models/user': User
	'./routes/resources': resources-router
	'./routes/index': index-router
}

RedisStore = connect-redis session

session-expires = 1000ms * 60seconds * 60minutes * 24hours * 365days # one year

web-server = express!
	..disable 'x-powered-by'
	..locals.compile-debug = false
	..set
		.. 'view engine' \jade
		.. 'views', __dirname + '/views'
	
	..use body-parser.urlencoded { +extended }
	..use cookie-parser config.cookie_pass

	# Session settings
	..use session do
		key: config.session-key
		secret: config.session-secret
		resave: no
		save-uninitialized: yes
		cookie:
			path: '/'
			domain: '.' + config.public-config.domain
			http-only: no
			secure: no
			expires: new Date Date.now! + session-expires
			max-age: session-expires
		store: new RedisStore do
			db: 1
			prefix: 'misskey-session:'

	# Compressing settings
	..use
		.. compression!
		.. minify!

	..init-session = (req, res, callback) ->
		res.set do
			'Access-Control-Allow-Origin': config.public-config.url
			'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
			'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE'
			'Access-Control-Allow-Credentials': yes
			'X-Frame-Options': \SAMEORIGIN

		req
			..login = req.session? && req.session.user-id?
			..data = # Render datas
				config: config
				url: config.public-config.url
				api-url: config.public-config.api-url
				login: req.login

		# Renderer function
		res.display = (req, res, name, render-data) -> res.render name, req.data <<< render-data

		if req.login
			user-id = req.session.user-id
			User.find-by-id user-id, (, user) ->
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
	..get '/favicon.ico' (, res,) ->
		res.sendFile path.resolve __dirname + '/resources/favicon.ico'
	
	..get '/manifest.json', (, res,) ->
		res.send-file path.resolve __dirname + '/resources/manifest.json'

# Resources rooting
resources-router web-server

# Init session
web-server.all '*' (req, res, next) -> web-server.init-session req, res, -> next!

# General rooting
index-router web-server

# Not found handling
web-server.use (req, res,) ->
	res
		..status 404
		..display req, res, 'notFound', {}

# Error handling
web-server.use (err, req, res,) ->
	res.status 500
	if res.has-own-property \display
		res.display req, res, 'error', err: err
	else
		console.log err
		res.send!

# Listen
web-server.listen config.port.web
