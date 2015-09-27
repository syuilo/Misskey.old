function init-read-before-statuses-button
	$button = $ \#read-before
	$button.click ->
		$button
			..attr \disabled on
			..attr \title '読み込み中...'
			..find \i .attr \class 'fa fa-spinner fa-pulse'

		$.ajax config.api-url + '/web/status/user-timeline-detail-one-html' {
			type: \get
			data: {
				'user-id': $ '#status .main > .status.article' .attr \data-user-id
				'max-cursor': $ \html .attr \data-before-source-cursor
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			#$button.remove!
			$button
				..attr \disabled off
				..attr \title 'これより前の投稿を読む'
				..find \i .attr \class 'fa fa-chevron-down'
			$status = $ data
			$ \html .attr \data-before-source-cursor $status.attr \data-timeline-cursor
			$status-item = $ '<li class="status">' .append $status
			window.STATUS_CORE.set-event $status-item.children '.status.article'
			$status-item.append-to $ '#before-timeline > .statuses' .hide! .slide-down 500ms
		.fail (data) ->
			$button
				..attr \disabled off
				..attr \title 'これより前の投稿を読む'
				..find \i .attr \class 'fa fa-chevron-down'

			window.display-message '読み込みに失敗しました。再度お試しください。'

function init-read-after-statuses-button
	$button = $ \#read-after
	$button.click ->
		$button
			..attr \disabled on
			..attr \title '読み込み中...'
			..find \i .attr \class 'fa fa-spinner fa-pulse'

		$.ajax config.api-url + '/web/status/user-timeline-detail-one-html' {
			type: \get
			data: {
				'user-id': $ '#status .main > .status.article' .attr \data-user-id
				'since-cursor': $ \html .attr \data-after-source-cursor
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			#$button.remove!
			$button
				..attr \disabled off
				..attr \title 'これより後の投稿を読む'
				..find \i .attr \class 'fa fa-chevron-up'
			$status = $ data
			$ \html .attr \data-after-source-cursor $status.attr \data-timeline-cursor
			$status-item = $ '<li class="status">' .append $status
			window.STATUS_CORE.set-event $status-item.children '.status.article'
			$status-item.prepend-to $ '#after-timeline > .statuses' .hide! .slide-down 500ms
		.fail (data) ->
			$button
				..attr \disabled off
				..attr \title 'これより後の投稿を読む'
				..find \i .attr \class 'fa fa-chevron-up'

			window.display-message '読み込みに失敗しました。再度お試しください。'

$ ->
	window.STATUS_CORE.set-event $ '#status .main .status.article'

	init-read-before-statuses-button!
	init-read-after-statuses-button!
