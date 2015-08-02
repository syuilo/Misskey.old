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
		res.status(403).send banned-compiler {ip: req.ip}
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
				done: no
		}
	else
		next!

# Define servers
app.use vhost \misskey.xyz (require "#__dirname/web/main" .server)
app.use vhost \api.misskey.xyz (require "#__dirname/api" .server)

# Create after listen HTTPS server
server = https.create-server certs, app
server.listen config.port.web-https
