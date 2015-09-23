require! {
	http
	ws: {Server: WebSocketServer}
	'../../config'
}

console.log 'Home streaming server loaded'

http-server = http.create-server (req, res) ->
	res
		..write-head 200 'Content-Type': 'text/plain'
		..end 'kyoppie'

ws-server = new WebSocketServer {
	server: http-server
	verify-client: (info) ->
		{'sauth-app-key': app-key, 'sauth-user-key': user-key} = info.req.headers
}

ws-server.on \connection (socket) ->
	{'sauth-app-key': app-key, 'sauth-user-key': user-key} = socket.upgrade-req.headers
	socket.on \message (message) ->
		socket.send "#message" # echo

http-server.listen config.port.streaming
