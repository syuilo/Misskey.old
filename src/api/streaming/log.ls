require! {
	redis
	jade
	'../../config'
}

module.exports = (io) ->
	io.of '/streaming/log' .on \connection (socket) ->
		
		socket.emit \connected
		
		subscriber = redis.create-client!
		subscriber.subscribe \misskey:log
		subscriber.on \message (, log) ->
			log = parse-json log
			compiler = jade.compile-file switch log.type
			| \web-incoming => "#__dirname/../../web/main/views/dynamic-parts/log/web-incoming.jade"
			| \web-outgoing => "#__dirname/../../web/main/views/dynamic-parts/log/web-outgoing.jade"
			| \api-incoming => "#__dirname/../../web/main/views/dynamic-parts/log/api-incoming.jade"
			| \api-outgoing => "#__dirname/../../web/main/views/dynamic-parts/log/api-outgoing.jade"
			socket.emit \log compiler log.value
			
		socket.on \disconnect ->
			# Disconnect redis
			subscriber.quit!
