require! {
	ws 
}

module.exports = (server) ->
	WebSocketServer = ws.Server
	wss = new WebSocketServer { server }