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

# Precompile
message = jade.render-file "#{__dirname}/views/maintenance.jade"

# Create server
web-server = express!

# General settings
web-server.disable 'x-powered-by'
web-server.use compression!
web-server.use minify!

# Catch all requests
web-server.all '*' (, res,) ->
	res.status 503
	res.send message

# Listen web port
web-server.listen config.port.web