require! {
	redis
	'../../config'
}

module.exports = (io, session-store) ->
	io.of '/streaming/log' .on \connection (socket) ->
		
		socket.emit \connected
		
		subscriber = redis.create-client!
		subscriber.subscribe \misskey:log
		subscriber.on \message (, log) ->
			socket.emit \log log

		socket.on \disconnect ->
			# Disconnect redis
			subscriber.quit!
