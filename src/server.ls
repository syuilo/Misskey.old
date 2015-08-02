require! {
	fs
	https
	express
	vhost
	'./config'
}

read-file = (path) -> fs.read-file-sync path .to-string!

# Read certs
certs =
	key: read-file "#__dirname/../../../certs/server.key"
	cert: read-file "#__dirname/../../../certs/startssl.crt"
	ca: read-file "#__dirname/../../../certs/sub.class1.server.ca.pem"

# Init express
app = express!
app.disable \x-powered-by

# Define servers
app.use vhost \misskey.xyz (require "#__dirname/web/main" .server)
app.use vhost \api.misskey.xyz (require "#__dirname/api" .server)

# Create after listen HTTPS server
server = https.create-server certs, app
server.listen config.port.web-https
