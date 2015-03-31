#
# Official web client HTTP server (https://misskey.xyz)
#

require! {
	fs
	path
	express
	compression
	'../config'
	'body-parser'
	'cookie-parser'
	'connect-redis': connect-redis
	'express-minify': minify
	'express-session': session
	'../models/user': User
	'./routes/resources': resources-router
	'./routes/index': index-router
}

# Init session store
RedisStore = connect-redis session

session-expires = 1000ms * 60seconds * 60minutes * 24hours * 365days # one year

# Create server
web-server = express!

# General settings
web-server.disable 'x-powered-by'
web-server.locals.compile-debug = off
web-server.set 'view engine' \jade
web-server.set 'views' "#__dirname/views"
web-server.set 'X-Frame-Options' \SAMEORIGIN

web-server.use body-parser.urlencoded {+extended}
web-server.use cookie-parser config.cookie-pass

# Session settings
web-server.use session do
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

# Compressing settings
web-server.use compression!
web-server.use minify!

# セッションを準備し、ユーザーがログインしているかどうかやデフォルトレンダリングデータを用意する
# セッションの確立が必要ないリソースなどへのアクセスでもこの処理を行うのは無駄であるので、任意のタイミングで処理を呼び出せるようにする
web-server.init-session = (req, res, callback) ->
	req.login = req.session? && req.session.user-id?
	req.data = # Render datas
		config: config
		url: config.public-config.url
		api-url: config.public-config.api-url
		login: req.login

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
web-server.get '/favicon.ico' (, res,) ->
	res.send-file path.resolve "#__dirname/resources/favicon.ico"
web-server.get '/manifest.json' (, res,) ->
	res.send-file path.resolve "#__dirname/resources/manifest.json"

# CORS middleware
#
# see: http://stackoverflow.com/questions/7067966/how-to-allow-cors-in-express-nodejs
allow-cross-domain = (req, res, next) ->
	res
		..header 'Access-Control-Allow-Credentials' yes
		..header 'Access-Control-Allow-Origin' config.public-config.url
		..header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE'
		..header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept'

    # intercept OPTIONS method
	if req.method == \OPTIONS
		res.send 204
	else
		next!

# CORS
web-server.use allow-cross-domain

# Timeout timer
web-server.all '*' (req, res, next) ->
	err = 'Sorry, processing timed out ><'
	set-timeout do
		->
			res.status 500
			if res.has-own-property \display
				res.display req, res, \error {err}
			else
				res.send err
		5000ms
	next!

# Resources rooting
resources-router web-server

# Init session
web-server.all '*' (req, res, next) -> web-server.init-session req, res, -> next!

# General rooting
index-router web-server

# Not found handling
web-server.use (req, res) ->
	res
		..status 404
		..display req, res, 'not-found' {}

# Error handling
web-server.use (err, req, res, next) ->
	console.log err
	res.status 500
	if res.has-own-property \display
		res.display req, res, \error {err}
	else
		res.send err

# Listen
web-server.listen config.port.web
