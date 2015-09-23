require! {
	http
	ws: WS
	'../../config'
}

console.log 'Home strreaming server loaded'

server = http.create-server (req, res) ->
	res
		..write-head 200 'Content-Type': 'text/plain'
		..end 'kyoppie'

WebSocketServer = WS.Server
wss = new WebSocketServer {server}

wss.on \connection (ws) ->
	ws.send 'kyoppie'

server.listen config.port.streaming
