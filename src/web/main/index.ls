require! {
	https
	fs
	path
	moment
	cors
	'../../utils/create-server'
	'../../utils/publish-redis-streaming'
	'../../utils/convert-string-to-color'
	'../../config'
	'body-parser'
	'cookie-parser'
	'connect-redis'
	'express-session': session
	'../../models/user': User
	'./resources': resources-router
	'./sites/desktop/router': desktop-router
	'./sites/mobile/router': mobile-router
}

RedisStore = connect-redis session

session-expires = 1000ms * 60seconds * 60minutes * 24hours * 365days

server = create-server!
server.locals.compile-debug = off
#server.locals.pretty = '  '
server.set 'view engine' \jade
server.set 'views' "#__dirname/views/pages"
server.set 'X-Frame-Options' \SAMEORIGIN

server.use cors	do
	credentials: on
	origin:
		* 'https://misskey.xyz'
		* 'https://misskey.xyz:1206'
		* 'http://dev.misskey.xyz'
		* 'http://dev.misskey.xyz:1205'
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
	uas = req.headers['user-agent']
	if uas?
		ua = uas.to-lower-case!
		is-mobile = /(iphone|ipod|ipad|android.*mobile|windows.*phone|psp|vita|nitro|nintendo)/i.test ua
		req.is-mobile = !!is-mobile
	else
		ua = null
		is-mobile = no
		req.is-mobile = no
	req.login = req.session? && req.session.user-id?
	req.data = # Render datas
		page-path: req.path
		config: config.public-config
		url: config.public-config.url
		api-url: config.public-config.api-url
		web-streaming-url: config.public-config.web-streaming-url
		login: req.login
		is-mobile: req.is-mobile
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

# Log
server.all '*' (req, res, next) ->
	next!
	uas = req.headers['user-agent']
	if uas?
		ua = uas.to-lower-case!
	else
		ua = null
	publish-redis-streaming \log to-json {
		type: \web
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

# Resources rooting
resources-router server

# Init session
server.all '*' (req, res, next) -> server.init-session req, res, -> next!

# General rooting
server.all '*' (req, res, next) ->
	if req.is-mobile
		server.set 'views' "#__dirname/sites/mobile/views/pages"
		desktop-router server
	else
		server.set 'views' "#__dirname/sites/desktop/views/pages"
		mobile-router server

# Not found handling
server.use (req, res) ->
	res
		..status 404
		..display req, res, 'not-found' {}

# Error handling
server.use (err, req, res, next) ->
	console.error err
	display-err = "#{err.stack}\r\n#{repeat 32 '-'}\r\n#{req.method} #{req.url} [#{new Date!}]"
	if (req.has-own-property \login) && req.login
		display-err += "\r\n#{req.me?id ? ''}"
	res.status 500
	if res.has-own-property \display
		res.display req, res, \error {err: display-err}
	else
		res.send err

exports.server = server
