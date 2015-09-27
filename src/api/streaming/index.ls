#
# Misskey StreaminAPI server
#

require! {
	http
	ws: {Server: WebSocketServer}
	redis
	'../../config'
	'../../utils/sauth-authorize'
	'../../models/status': Status
	'../../models/user': User
	'../../models/notice': Notice
	'../../models/utils/get-app-from-app-key'
	'../../models/utils/get-user-from-user-key'
	'../../models/utils/notice-serialyzer'
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
	
	function send-event(type, data)
		obj = {
			event: type
			data: data
		}
		socket.send JSON.stringify obj
	
	# Load app and user instances
	get-app-from-app-key app-key .then (app) ->
		get-user-from-user-key user-key .then (user) ->
			
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
						send-event \status-update status.to-object!
					| \notice =>
						# Find notice
						err, notice <- Notice.find-by-id content.value.id
						notice-serialyzer notice .then (serialized-notice) ->
							send-event \notice serialized-notice
					| \talk-message =>
						# Find sender
						err, user <- User.find-by-id content.value.user-id
						send-event \talk-message {
							id: content.value.id
							text: content.value.text
							user: user.to-object!
						}
			
			socket.on \close ->
				subscriber.end!
			
	socket.on \message (message) ->
		socket.send "app-key: #{app-key}, user-key: #{user-key}, message: #{message}" # echo

http-server.listen config.port.streaming
