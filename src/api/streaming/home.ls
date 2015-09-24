require! {
	http
	ws: {Server: WebSocketServer}
	'../../config'
	'../../utils/sauth-authorize'
}

console.log 'Home streaming server loaded'

http-server = http.create-server (req, res) ->
	res
		..write-head 200 'Content-Type': 'text/plain'
		..end 'kyoppie'

ws-server = new WebSocketServer {
	server: http-server
	verify-client: !(info, cb) ->
		cb true
		#{'sauth-app-key': app-key, 'sauth-user-key': user-key} = info.req.headers
		#sauth-authorize app-key, user-key .then (!-> cb true), (!(error-name) -> cb true 401 error-name)
		#void
}

ws-server.on \connection (socket) ->
	{'sauth-app-key': app-key, 'sauth-user-key': user-key} = socket.upgrade-req.headers
	socket.on \message (message) ->
		socket.send "app-key: #app-key, user-key: #user-key, message: #message" # echo

http-server.listen config.port.streaming
