################################
# Servers Loader
################################

require! {
	fs
	http
	https
	express
	vhost
	jade
	'./utils/publish-redis-streaming'
	'./utils/convert-string-to-color'
	'./banned-ips': banned-ips
	'./config'
}

console.log 'Servers loader loaded'

# Init express
app = express!
app.disable \x-powered-by

server = http.create-server app

read-file = (path) -> fs.read-file-sync path .to-string!
banned-compiler = jade.compile-file "#__dirname/banned.jade"

## Read certs
#certs =
#	key: read-file "#__dirname/../../../certs/server.key"
#	cert: read-file "#__dirname/../../../certs/startssl.crt"
#	ca: read-file "#__dirname/../../../certs/sub.class1.server.ca.pem"

# Check IP
app.all '*' (req, res, next) ->
	if (banned-ips.index-of req.ip) > -1
		# Compile after send
		res.status(403).send banned-compiler {ip: req.ip}

		# Log
		ua = req.headers['user-agent'].to-lower-case!
		type = switch (req.hostname)
			| \misskey.xyz => \web
			| \api.misskey.xyz => \api
		publish-redis-streaming \log to-json {
			type: type
			value:
				date: Date.now!
				remote-addr: req.ip
				protocol: req.protocol
				method: req.method
				path: req.path
				ua: ua
				color: convert-string-to-color req.ip
				done: no}
	else
		next!

# Define servers
main-server = require "#__dirname/web/main" .server
api-server = require "#__dirname/api" .server
streaming-server = require "#__dirname/api/streaming" .server
#web-streaming-server = require "#__dirname/api/web-streaming-server" .server
dev-server = require "#__dirname/web/dev" .server
app.use vhost \misskey.xyz main-server
app.use vhost \api.misskey.xyz api-server
#app.use vhost \web-streaming.misskey.xyz web-streaming-server
app.use vhost \streaming.misskey.xyz streaming-server
app.use vhost \dev.misskey.xyz dev-server

require "#__dirname/api/web-streaming-server"

## Listen HTTPS server after create
#https.create-server certs, app .listen config.port.web-https

# Listen core app
server.listen config.port.web-http

## Redirect HTTP
#http-app = express!
#http-app.disable \x-powered-by
#http-app.use vhost \misskey.xyz (req, res) -> res.redirect "https://misskey.xyz#{req.url}"
#http-app.use vhost \dev.misskey.xyz (require "#__dirname/web/dev" .server)
#http.create-server http-app .listen config.port.web-http
