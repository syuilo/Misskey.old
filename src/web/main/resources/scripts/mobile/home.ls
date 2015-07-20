prelude = require 'prelude-ls'

window.STATUSTIMELINE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true
		
		function check-reposted
			($status.attr \data-is-reposted) == \true
			
		text = $status.attr \data-text
		
		$status
			# Init favorite button
			..find 'article > .article-main > .main > .footer > .actions > .favorite > .favorite-button' .click ->
				$button = $ @
					..attr \disabled on
				if check-favorited!
					$status.attr \data-is-favorited \false
					$.ajax "#{config.api-url}/status/unfavorite" {
						type: \delete
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-favorited \true
				else
					$status.attr \data-is-favorited \true
					$.ajax "#{config.api-url}/status/favorite" {
						type: \post
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-favorited \false
			
			# Init repost button
			..find 'article > .article-main > .main > .footer > .actions > .repost > .repost-button' .click ->
				if window.confirm "「#{text}」をRepostしますか？"
					$button = $ @
						..attr \disabled on
					if check-reposted!
						$status.attr \data-is-reposted \false
						$.ajax "#{config.api-url}/status/unrepost" {
							type: \delete
							data: {'status-id': $status.attr \data-id}
							data-type: \json
							xhr-fields: {+withCredentials}}
						.done ->
							$button.attr \disabled off
						.fail ->
							$button.attr \disabled off
							$status.attr \data-is-reposted \true
					else
						$status.attr \data-is-reposted \true
						$.ajax "#{config.api-url}/status/repost" {
							type: \post
							data: {'status-id': $status.attr \data-id}
							data-type: \json
							xhr-fields: {+withCredentials}}
						.done ->
							$button.attr \disabled off
						.fail ->
							$button.attr \disabled off
							$status.attr \data-is-reposted \false
			
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

	socket = io.connect config.web-streaming-url + '/streaming/web/mobile/home'

	socket.on \connect ->
		console.log 'Connected'

	socket.on \disconnect (client) ->

	socket.on \status (status) ->
		add-status $ status

	$ '#timeline .load-more' .click ->
		$button = $ @
		$button.attr \disabled yes
		$button.text 'Loading...'
		$.ajax config.api-url + '/web/status/timeline-homehtml' {
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
			# Attach Wave effects 
			init-waves-effects!
		.fail (data) ->
			$button.attr \disabled no
			$button.text 'Failed...'
