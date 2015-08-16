################################
# Core Server
################################

require! {
	fs
	https
	express
	vhost
	jade
	'./utils/publish-redis-streaming'
	'./utils/convert-string-to-color'
	'./banned-ips': banned-ips
	'./config'
}

read-file = (path) -> fs.read-file-sync path .to-string!
banned-compiler = jade.compile-file "#__dirname/banned.jade"

# Read certs
certs =
	key: read-file "#__dirname/../../../certs/server.key"
	cert: read-file "#__dirname/../../../certs/startssl.crt"
	ca: read-file "#__dirname/../../../certs/sub.class1.server.ca.pem"

# Init express
app = express!
app.disable \x-powered-by

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
app.use vhost \misskey.xyz (require "#__dirname/web/main" .server)
app.use vhost \api.misskey.xyz (require "#__dirname/api" .server)
#app.use vhost \dev.misskey.xyz (require "#__dirname/web/dev" .server)

# Listen HTTPS server after create 
https.create-server certs, app .listen config.port.web-https

# Redirect HTTP
http-app = express!
http-app.disable \x-powered-by
http-app.use vhost \misskey.xyz (req, res) -> res.redirect 'https://misskey.xyz'
http-app.use vhost \dev.misskey.xyz (req, res) -> (require "#__dirname/web/dev" .server)
http-app.listen config.port.web-http