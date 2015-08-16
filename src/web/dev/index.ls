require! {
	https
	fs
	path
	moment
	'../../utils/create-server'
	'body-parser'
	'cookie-parser'
	'connect-redis'
	'express-session': session
	'../../models/user': User
	'./routes/resources': resources-router
	'./routes/index': index-router
	'../../config'
}

RedisStore = connect-redis session

session-expires = 1000ms * 60seconds * 60minutes * 24hours * 365days

server = create-server!
server.locals.compile-debug = off
server.set 'view engine' \jade
server.set 'views' "#__dirname/views/pages"
server.set 'X-Frame-Options' \SAMEORIGIN

server.use body-parser.urlencoded {+extended}
server.use cookie-parser config.cookie-pass

# Session settings
server.use session do
	key: config.session-key
	secret: config.session-secret
	resave: off
	save-uninitialized: on
	cookie:
		path: '/'
		domain: ".#{config.public-config.domain}"
		http-only: off
		secure: off
		expires: new Date Date.now! + session-expires
		max-age: session-expires
	store: new RedisStore do
		db: 1
		prefix: 'misskey-session:'

server.init-session = (req, res, callback) ->
	req.login = req.session? && req.session.user-id?
	req.data = # Render datas
		page-path: req.path
		config: config.public-config
		url: config.public-config.url
		api-url: config.public-config.api-url
		web-streaming-url: config.public-config.web-streaming-url
		login: req.login
		moment: moment

	# Renderer function
	res.display = (req, res, name, render-data) -> res.render name, req.data <<< render-data

	# Check logged in, set user instance
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
server.get '/favicon.ico' (req, res) -> res.send-file path.resolve "#__dirname/resources/favicon.ico"
server.get '/manifest.json' (req, res) -> res.send-file path.resolve "#__dirname/resources/manifest.json"

server.all '*' (req, res, next) ->
	console.log \yuppie
	next!

# Resources rooting
#resources-router server

# Init session
server.all '*' (req, res, next) -> server.init-session req, res, -> next!

# General rooting
index-router server

# Not found handling
server.use (req, res) ->
	res
		..status 404
		..display req, res, 'not-found' {}
		
exports.server = server