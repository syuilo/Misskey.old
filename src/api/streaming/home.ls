require! {
	http
	ws: WS
	'../../config'
}

console.log 'Home streaming server loaded'

server = http.create-server (req, res) ->
	res
		..write-head 200 'Content-Type': 'text/plain'
		..end 'kyoppie'

WebSocketServer = WS.Server
wss = new WebSocketServer {
	server: server
	verify-client: (info) ->
		{'sauth-app-key': app-key, 'sauth-user-key': user-key} = info.req.headers
}

wss.on \connection (socket) ->
	{'sauth-app-key': app-key, 'sauth-user-key': user-key} = ws.upgradeReq.headers
	socket.on \message (message) ->
		ws.send "#message" # echo

server.listen config.port.streaming
