require! {
	http
	ws: WS
	'../../config'
}

module.exports = (server) ->
	server = http.create-server (req, res) ->
		res
			..write-head 200 'Content-Type': 'text/plain'
			..end 'kyoppie'

	WebSocketServer = WS.Server
	wss = new WebSocketServer {port: config.ports.streaming}

	wss.on \connection (ws) ->
		ws.send 'kyoppie'
