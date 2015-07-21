function add-status($status)
	new Audio '/resources/sounds/pop.mp3' .play!
		
	$status = $ '<li class="status">' .append($status)
	$recent-status = ($ ($ '#timeline .timeline > .statuses > .status')[0]) .children \.status
	if ($recent-status.attr \data-display-html-is-active) == \true
		$status.children \.status .add-class \display-html-active-status-prev
	window.STATUSTIMELINE.set-event $status.children '.status.article'
	$status.prepend-to ($ '#timeline .timeline > .statuses')

$ ->	
	$ '.timeline .statuses .status .status.article' .each ->
		window.STATUSTIMELINE.set-event $ @
	
	#$ '#misskey-main-header .post' .click ->
	#	text = window.prompt '新規投稿'
	#	if text?
	#		#
	#	false

	socket = io.connect config.web-streaming-url + '/streaming/web/mobile/home'

	socket.on \connect ->
		console.log 'Connected'

	socket.on \disconnect (client) ->

	socket.on \status (status) ->
		add-status $ status
	
	socket.on \repost (status) ->
		add-status $ status

	$ '#timeline .load-more' .click ->
		$button = $ @
		$button.attr \disabled yes
		$button.text 'Loading...'
		$.ajax config.api-url + '/web/status/timeline-mobilehomehtml' {
			type: \get
			data: {
				'max-cursor': $ '#timeline .timeline > .statuses > .status:last-child > .status.article' .attr \data-timeline-cursor
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$button.attr \disabled no
			$button.text 'Read more!'
			$statuses = $ data
			$statuses.each ->
				$status = $ '<li class="status">' .append $ @
				window.STATUSTIMELINE.set-event $status.children '.status.article'
				$status.append-to $ '#timeline .timeline > .statuses'
		.fail (data) ->
			$button.attr \disabled no
			$button.text 'Failed...'
