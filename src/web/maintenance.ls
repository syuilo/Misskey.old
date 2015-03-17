require! {
	jade
	express
	'express-minify': minify
	'compression': compress
	'../config': config
}

message = jade.render-file __dirname + '/views/maintenance.jade'

web-server = express!
	..disable 'x-powered-by'
	..use compress!
	..use minify!
	..all '*' (req, res, next) ->
		res
			..status 503
			..send message
	..listen config.port.web
