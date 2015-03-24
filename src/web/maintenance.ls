#
# Maintenance page HTTP server
#

require! {
	jade
	express
	compression
	'../config'
	'express-minify': minify
}

message = jade.render-file "#{__dirname}/views/maintenance.jade"

web-server = express!
	..disable 'x-powered-by'
	..use compression!
	..use minify!
	..all '*' (, res,) ->
		res
			..status 503
			..send message
	..listen config.port.web
