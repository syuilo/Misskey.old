$ ->
	socket = io.connect "#{config.web-streaming-url}/streaming/log"

	socket.on \connected ->
		console.log 'Connected'

	socket.on \disconnect ->
		console.log 'Disconnected'

	socket.on \log (log) ->
		console.log \log log
		$log = $ log
		$log = $ '<li class="log">' .append $message
		$log.append-to $ \#logs
		scroll 0, ($ \html .outer-height!)
