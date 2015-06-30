require! {
	redis
	jade
	'../../config'
}

module.exports = (io) ->
	web-incoming-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/log/web-incoming.jade"
	web-outgoing-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/log/web-outgoing.jade"
	api-incoming-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/log/api-incoming.jade"
	api-outgoing-compiler = jade.compile-file "#__dirname/../../web/main/views/dynamic-parts/log/api-outgoing.jade"
	
	io.of '/streaming/log' .on \connection (socket) ->
		
		socket.emit \connected
		
		subscriber = redis.create-client!
		subscriber.subscribe \misskey:log
		subscriber.on \message (, log) ->
			log = parse-json log
			compiler = switch log.type
			| \web-incoming => web-incoming-compiler
			| \web-outgoing => web-outgoing-compiler
			| \api-incoming => api-incoming-compiler
			| \api-outgoing => api-outgoing-compiler
			socket.emit \log compiler log.value
			
		socket.on \disconnect ->
			# Disconnect redis
			subscriber.quit!
