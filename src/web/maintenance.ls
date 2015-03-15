require! {
	jade
	express
	'express-minify': minify
	'compression': compress
	'../config': config
}

web-server = express!
	..disable 'x-powered-by'
	..use compress!
	..use minify!

/* Precompile */
message = jade.renderFile(__dirname + '/views/maintenance.jade')

/* General routing */
webServer.all '*', (req, res, next) ->
	res
		..status 503
		..send message

webServer.listen config.port.web
