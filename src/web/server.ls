require! {
	fs
	path
	'../utils/create-server'
	'../config'
	'body-parser'
	'cookie-parser'
	'connect-redis'
	'express-session': session
	'../models/user': User
	'./routes/resources': resources-router
	'./routes/index': index-router
}

RedisStore = connect-redis session

session-expires = 1000ms * 60seconds * 60minutes * 24hours * 365days

server = create-server!
server.locals.compile-debug = off
server.locals.pretty = '  '
server.set 'view engine' \jade
server.set 'views' "#__dirname/views"
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

# セッションを準備し、ユーザーがログインしているかどうかやデフォルトレンダリングデータを用意する
# セッションの確立が必要ないリソースなどへのアクセスでもこの処理を行うのは無駄であるので、任意のタイミングで処理を呼び出せるようにする
server.init-session = (req, res, callback) ->
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
server.get '/favicon.ico' (req, res) -> res.send-file path.resolve "#__dirname/resources/favicon.ico"
server.get '/manifest.json' (req, res) -> res.send-file path.resolve "#__dirname/resources/manifest.json"

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
server.use allow-cross-domain

# Timeout timer
server.all '*' (req, res, next) ->
	if req.url != '/login'
		set-timeout do
			->
				try
					res.status 500
					if res.has-own-property \display
						res.display req, res, \timeout {}
					else
						res.send 'Sorry, processing timed out ><'
				catch
			3000ms
		next!
	else
		next!

# Resources rooting
resources-router server

# Init session
server.all '*' (req, res, next) -> server.init-session req, res, -> next!

# General rooting
index-router server

# Not found handling
server.use (req, res) ->
	res
		..status 404
		..display req, res, 'not-found' {}

# Error handling
server.use (err, req, res, next) ->
	console.error err
	display-err = '''
#{err.stack}
#{repeat 32 '-'}
#{req.method} #{req.url} [#{new Date!}]'''
	if (req.has-own-property \login) && req.login
		display-err += "\r\n#{req.me.id}"
	res.status 500
	if res.has-own-property \display
		res.display req, res, \error { err: display-err }
	else
		res.send err

# Listen
server.listen config.port.web
