require! {
	express
	vhost
	'./config'
}

https-server = express!
https-server.disable \x-powered-by
https-server.use vhost \misskey.xyz (req, res) ->
	require "#__dirname/web/main" .server.emit \request req, res
#https-server.use vhost \misskey.xyz (require "#__dirname/web/main" .server)
#https-server.use vhost \api.misskey.xyz (require "#__dirname/api" .server)
https-server.listen config.port.web-https

http-server = express!
http-server.disable \x-powered-by
http-server.listen config.port.web-http
