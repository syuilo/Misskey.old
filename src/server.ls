require! {
	express
	'./config'
}

server = express!
server.disable 'x-powered-by'
server.use express.vhost('api.misskey.xyz', require("#__dirname/api").app)
server.use express.vhost('misskey.xyz', require("#__dirname/web/main").app)
server.listen config.port.web-https