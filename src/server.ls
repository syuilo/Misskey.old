require! {
	express
	vhost
	'./config'
}

server = express!
server.disable 'x-powered-by'
server.use vhost 'api.misskey.xyz' (require "#__dirname/api" .server)
server.use vhost 'misskey.xyz' (require "#__dirname/web/main" .server)
server.listen config.port.web-http