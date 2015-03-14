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

web-server = express!
web-server.disable 'x-powered-by'
web-server.set 'view engine' \jade
web-server.set 'views', __dirname + '/views'
web-server.locals.compile-debug = false

web-server.use body-parser.urlencode extended: true
web-server.use cookie-parser config.cookie_pass

year = (60 * 60 * 24 * 365) * 1000

# Session settings
web-server.use session do
	key: config.session-key
	secret: config.session-secret
	resave: false
	saveUninitialized: true
	cookie:
		path: '/'
		domain: '.' + config.public-config.domain
		http-only: false
		secure: false
		expires: new Date(Date.now! + year)
		max-age: year
	store: new RedisStore do
		db: 1
		prefix: 'misskey-session:'

# Compressing settings
web-server.use compress!
web-server.use minify!

web-server.init-session = (req, res: any, callback) ->
	res.set do
		'Access-Control-Allow-Origin': config.public-config.url
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
		'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE'
		'Access-Control-Allow-Credentials': true
		'X-Frame-Options': \SAMEORIGIN

	# Is logged
	req.login = (req.session != null && req.session.user-id != null)

	# Render datas
	req.data =
		config: config
		url: config.public-config.url
		api-url: config.public-config.api-url
		login: req.login

	# Renderer function
	res.display = (req, res, name, render-data) -> res.render name, req.data <<< render-data

	if req.login
		user-id = req.session.user-id
		User.find user-id, (user) ->
			Notice.find-byuser-id user.id, (notices) ->
				if notices != null
					async.map notices, (notice, next) ->
						Application.find notice.appId, (app) -> next null, notice.app
					, (err, results) ->
						req.data.notices = results
						req.data.me = user
						req.me = user
						callback!
				else
					req.data.me = user
					req.me = user
					callback!
	else
		req.data.me = null
		req.me = null
		callback!

# Statics
webServer.get '/favicon.ico' (req, res, next) ->
	res.sendFile path.resolve(__dirname + '/resources/favicon.ico')
	
webServer.get '/manifest.json', (req, res, next) ->
	res.sendFile path.resolve(__dirname + '/resources/manifest.json')

# Resources rooting
resourcesRouter webServer

# General rooting
webServer.all '*' (req, res, next) ->
	webServer.initSession req, res, -> next!

indexRouter webServer

# Not found handling
webServer.use (req, res, next) ->
	res.status 404
	res.display req, res, 'notFound', {}

# Error handling
webServer.use (err, req, res, next) ->
	res.status 500
	if res.hasOwnProperty 'display'
		res.display req, res, 'error', err: err
	else
		console.log err
		res.send!

webServer.listen config.port.web
