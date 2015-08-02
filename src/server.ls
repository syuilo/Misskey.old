require! {
	fs
	https
	express
	vhost
	'./config'
}

read-file = (path) -> fs.read-file-sync path .to-string!

certs =
	key: read-file "#__dirname/../../../certs/server.key"
	cert: read-file "#__dirname/../../../certs/startssl.crt"
	ca: read-file "#__dirname/../../../certs/sub.class1.server.ca.pem"

app = express!
app.disable \x-powered-by
app.use vhost \misskey.xyz (require "#__dirname/web/main" .server)
app.use vhost \api.misskey.xyz (require "#__dirname/api" .server)

server = https.create-server certs, app
server.listen config.port.web-https
