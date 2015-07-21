prelude = require 'prelude-ls'

$ ->	
	$ '.timeline .statuses .status .status.article' .each ->
		window.STATUSTIMELINE.set-event $ @
	
	$ '#misskey-main-header .post' .click ->
		#if $.cookie \quick-post-autosave
		#	dflt = $.cookie \quick-post-autosave
		#else
		#	dflt = null
		text = window.prompt '新規投稿'
		if text? and text != ''
			$.ajax config.api-url + '/status/update' {
				type: \post
				data: {text}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done (data) ->
				$.remove-cookie \quick-post-autosave {path: '/'}
			.fail (data) ->
				error-code = JSON.parse data.response-text .error.code
				switch error-code
				| \empty-text => window.alert 'テキストを入力してください。'
				| \too-long-text => window.alert 'テキストが長過ぎます。'
				| \duplicate-content => window.alert '投稿が重複しています。'
				| \failed-attach-image => window.alert '画像の添付に失敗しました。Misskeyが対応していない形式か、ファイルが壊れているかもしれません。'
				| _ => window.alert "不明なエラー (#error-code)"

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
