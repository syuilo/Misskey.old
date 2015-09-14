function check-can-scroll
	$window = $ window
	height = $window.height!
	scroll-top = $window.scroll-top!
	document-height = $ document .height!
	height + scroll-top >= (document-height - 64px)

$ ->
	socket = io.connect "#{config.web-streaming-url}/streaming/log"

	socket.on \connected ->
		console.log 'Connected'

	socket.on \disconnect ->
		console.log 'Disconnected'

	socket.on \log (log) ->
		if check-can-scroll!
			$log = $ log
			$log.append-to $ \#logs
			if ($ \#logs .children \li .length) > 1024
				($ \#logs .children \li)[0].remove!
			scroll 0, ($ \html .outer-height!)
			
