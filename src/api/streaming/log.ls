require! {
	redis
	jade
	'../../config'
}

module.exports = (io) ->
	web-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/log/web.jade"
	api-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/log/api.jade"
	
	io.of '/streaming/log' .on \connection (socket) ->
		
		socket.emit \connected
		
		subscriber = redis.create-client!
		subscriber.subscribe \misskey:log
		subscriber.on \message (, log) ->
			log = parse-json log
			compiler = switch log.type
			| \web => web-compiler
			| \api => api-compiler
			socket.emit \log compiler log.value
			
		socket.on \disconnect ->
			# Disconnect redis
			subscriber.quit!
