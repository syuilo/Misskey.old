$ ->
	$ \#left-sub-contents .css \padding-top "#{$ \#comment .outer-height! - 16px}px"

	$ '#timeline .statuses .status .status.article' .each ->
		window.STATUS_CORE.set-event $ @
	
	# Read more
	$ window .scroll ->
		me = $ @
		current = $ window .scroll-top! + window.inner-height
		if current > $ document .height! - 32
			if not me.data \loading
				me.data \loading yes
				$.ajax config.api-url + '/web/status/user-timeline-detailhtml' {
					type: \get
					data: {
						'user-id': $ \html .attr \data-user-id
						'max-cursor': $ '#timeline .timeline > .statuses > .status:last-child > .status.article' .attr \data-timeline-cursor
					}
					data-type: \json
					xhr-fields: {+with-credentials}}
				.done (data) ->
					me.data \loading no
					$statuses = $ data
					$statuses.each ->
						$status = $ '<li class="status">' .append $ @
						window.STATUS_CORE.set-event $status.children '.status.article'
						$status.append-to $ '#timeline .timeline > .statuses'
				.fail (data) ->
					me.data \loading no
