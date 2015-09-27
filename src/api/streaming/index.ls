#
# Misskey StreaminAPI server
#

require! {
	http
	ws: {Server: WebSocketServer}
	redis
	'../../config'
	'../../utils/sauth-authorize'
	'../../models/utils/get-app-from-app-key'
	'../../models/utils/get-user-from-user-key'
}

console.log 'Streaming API Server loaded'

http-server = http.create-server (req, res) ->
	res
		..write-head 200 'Content-Type': 'text/plain'
		..end 'kyoppie'

ws-server = new WebSocketServer do
	server: http-server
	verify-client: !(info, cb) ->
		{'sauth-app-key': app-key, 'sauth-user-key': user-key} = info.req.headers
		sauth-authorize app-key, user-key .then (!-> cb true), (!(error-name) -> cb false 401 error-name)
		void

ws-server.on \connection (socket) ->
	{'sauth-app-key': app-key, 'sauth-user-key': user-key} = socket.upgrade-req.headers
	
	# Load app and user instances
	get-app-from-app-key app-key .then (app) ->
		get-user-from-user-key user-key (user) ->
			
			# Subscribe stream
			subscriber = redis.create-client!
			subscriber.subscribe "misskey:userStream:#{user.id}"
			
			subscriber.on \message (, content) ->
				content = parse-json content
				if content.type? && content.value?
					switch content.type
					| \status, \repost =>
						# Find status
						err, status <- Status.find-by-id content.value.id
						socket.send status.to-object!
			
			socket.on \message (message) ->
				socket.send "app-key: #{app-key}, user-key: #{user-key}, message: #{message}" # echo

http-server.listen config.port.streaming
