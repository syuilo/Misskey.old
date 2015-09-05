require! {
	ws: WS
}

module.exports = (server) ->
	WebSocketServer = WS.Server
	wss = new WebSocketServer { server }
	
	wss.on \connection (ws) ->
		ws.send 'kyoppie'
