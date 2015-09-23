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
		console.log info.req.headers['sauth-app-key']
		console.log info.req.headers['sauth-user-key']
		true
}

wss.on \connection (ws) ->
	ws.send 'Connected! Welcome to Misskey.'

	ws.on \message (message) ->
		console.log "received: #message"
		ws.send "#message" # echo

server.listen config.port.streaming
