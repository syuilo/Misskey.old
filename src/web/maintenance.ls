require! {
	jade
	'../utils/create-server'
	'../config'
}

message = jade.render-file "#{__dirname}/views/maintenance.jade"

server = create-server!
server.all '*' (req, res) ->
	res.status 503
	res.send message
server.listen config.port.web
