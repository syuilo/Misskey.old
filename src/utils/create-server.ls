require! {
	express
	comperssion
	'express-minify'
}

create-server = ->
	server = express!
	server.disable 'x-powered-by'
	server.use comperssion
	server.use express-minify
	server

module.exports = create-server
