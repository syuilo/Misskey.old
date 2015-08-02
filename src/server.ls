require! {
	fs
	https
	express
	vhost
	'./config'
}

read-file = (path) -> fs.read-file-sync path .to-string!

https-server = express!
https-server.disable \x-powered-by
https-server.use vhost \misskey.xyz (req, res) ->
	console.log 'yuppie'
	server = https.create-server do
		key: read-file "#__dirname/../../../certs/server.key"
		cert: read-file "#__dirname/../../../certs/startssl.crt"
		ca: read-file "#__dirname/../../../certs/sub.class1.server.ca.pem"
		(req, res) ->
			res.end 'kyoppie'
			console.log 'kyoppie'
	server.emit \request req, res
	#require "#__dirname/web/main" .server.emit \request req, res
#htt1ps-server.use vhost \misskey.xyz (require "#__dirname/web/main" .server)
#https-server.use vhost \api.misskey.xyz (require "#__dirname/api" .server)
https-server.listen config.port.web-https

http-server = express!
http-server.disable \x-powered-by
http-server.listen config.port.web-http
