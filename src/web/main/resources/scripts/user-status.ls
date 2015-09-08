function init-read-before-statuses-button
	$button = $ \#read-before
		..attr \disabled on
		..attr \title '読み込み中...'
		..find \i .attr \class 'fa fa-spinner fa-pulse'

	$.ajax config.api-url + '/web/status/user-timeline-detailhtml' {
		type: \get
		data: {
			'max-cursor': $ '#status .main > .status.article' .attr \data-timeline-cursor
		}
		data-type: \json
		xhr-fields: {+with-credentials}}
	.done (data) ->
		$button.remove!
		$statuses = $ data
		$statuses.each ->
			$status = $ '<li class="status">' .append $ @
			window.STATUS_CORE.set-event $status.children '.status.article'
			$status.append-to $ '#before-timeline > .statuses'
	.fail (data) ->
		$button = $ @
			..attr \disabled off
			..attr \title 'これより前の投稿を読む'
			..find \i .attr \class 'fa fa-angle-down'

		window.display-message '読み込みに失敗しました。再度お試しください。'

function init-read-after-statuses-button
	\kyoppie

$ ->
	window.STATUS_CORE.set-event $ '#status .main .status.article'

	init-read-before-statuses-button!
	init-read-after-statuses-button!
