require! {
	express
	vhost
	'./config'
}

server = express!
server.disable 'x-powered-by'
server.use vhost 'api.misskey.xyz' (require "#__dirname/api" .app)
server.use vhost 'misskey.xyz' (require "#__dirname/web/main" .app)
server.listen config.port.web-https