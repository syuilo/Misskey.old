function add-status($status)
	new Audio '/resources/sounds/pop.mp3' .play!
		
	$status = $ '<li class="status">' .append($status).hide!
	$recent-status = ($ ($ '#timeline .timeline > .statuses > .status')[0]) .children \.status
	if $recent-status.attr \data-display-html-is-active == \true
		$status.add-class \display-html-active-status-prev
	window.STATUSTIMELINE.set-event $status.children '.status.article'
	$status.prepend-to ($ '#timeline .timeline > .statuses') .show 200
	
	# Attach Wave effects 
	init-waves-effects!

$ ->
	try
		Notification.request-permission!
	catch
		console.log 'oops'
	
	$ \#notices .hover do
		-> $ '#notices .nav' .show 200ms
		-> $ '#notices .nav' .hide 200ms

	# オートセーブがあるなら復元
	if $.cookie \post-autosave
		$ '#post-form textarea' .val $.cookie \post-autosave
	
	# 通知読み込み
	$.ajax config.api-url + '/notice/timeline-webhtml' {
		type: \get
		data: {}
		data-type: \json
		xhr-fields: {+with-credentials}}
	.done (data) ->
		if data != ''
			$notices = $ data
			$notices.each ->
				$notice = $ @
				$notice.append-to $ '#notices .notices'
		else
			$info = $ '<p class="notice-empty">通知はありません</p>'
			$info.append-to $ '#notices'
	.fail (data) ->

	socket = io.connect config.web-streaming-url + '/streaming/web/home'

	socket.on \connect ->
		console.log 'Connected'

	socket.on \disconnect (client) ->
		
	socket.on \notice (notice) ->
		console.log \notice notice
		
		$ '#notices .notice-empty' .remove!
		
		$notice = ($ notice).hide!
		$notice.prepend-to ($ '#notices .notices') .show 200

	socket.on \status (status) ->
		console.log \status status
		add-status $ status

	socket.on \repost (status) ->
		console.log \repost status
		add-status $ status

	socket.on \reply (status) ->
		console.log \reply status
		
		id = status.id
		name = status.user-name
		sn = status.user-screen-name
		text = status.text
		n = new Notification name, {
			body: text
			icon: "#{conf.url}/img/icon/#sn"
		}
		n.onshow = ->
			set-timeout n.close, 10000ms
		n.onclick = ->
			window.open "#{conf.url}/#{sn}/status/#{id}"

	socket.on \talk-message (message) ->
		console.log \talk-message message
		window-id = 'misskey-window-talk-' + message.user.id
		if $('#' + window-id).0
			return
		n = new Notification message.user.name, {
			body: message.text,
			icon: conf.url + '/img/icon/' + message.user.screenName
		}
		n.onshow = ->
			set-timeout n.close, 10000ms
		n.onclick = ->
			url = config.url + '/' + message.user.screen-name + '/talk?noheader=true'
			$content = $ '<iframe>' .attr {
				src: url
				+seamless
			}
			open-window do
				window-id
				$content
				'<i class="fa fa-comments"></i>' + escapeHTML message.user.name
				300
				450
				true
				url

	$ \#post-form .find '.image-attacher input[name=image]' .change ->
		$input = $ @
		file = $input.prop(\files).0
		if file.type.match 'image.*'
			reader = new FileReader!
			reader.onload = ->
				$img = $ '<img>' .attr \src reader.result
				$input.parent '.image-attacher' .find 'p, img' .remove!
				$input.parent '.image-attacher' .append $img
			reader.read-as-dataURL file

	$ window .keypress (e) ->
		if e.char-code == 13 && e.ctrl-key
			post $ '#postForm textarea'

	$ \#post-form .submit (event) ->
		event.prevent-default!
		post $ @

	function post($form)
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.attr \value 'Updating...'

		$.ajax config.api-url + '/status/update' {
			type: \post
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$form[0].reset!
			$form.find \textarea .focus!
			$form.find \.image-attacher .find 'p, img' .remove!
			$form.find \.image-attacher .append $ '<p><i class="fa fa-picture-o"></i></p>'
			$submit-button.attr \disabled no
			$submit-button.attr \value 'Update \uf1d8'
			$.remove-cookie \post-autosave
			window.display-message '投稿しました！'
		.fail (data) ->
			#$form[0].reset!
			$form.find \textarea .focus!
			$submit-button.attr \disabled no
			$submit-button.attr \value 'Update \uf1d8'
			error-code = JSON.parse data.response-text .error.code
			switch error-code
			| \empty-text => window.display-message 'テキストを入力してください。'
			| \too-long-text => window.display-message 'テキストが長過ぎます。'
			| \duplicate-content => window.display-message '投稿が重複しています。'
			| \failed-attach-image => window.display-message '画像の添付に失敗しました。Misskeyが対応していない形式か、ファイルが壊れているかもしれません。'
			| _ => window.display-message "不明なエラー (#error-code)"
	
	$ '#post-form textarea' .bind \input ->
		text = $ '#post-form textarea' .val!

		# オートセーブ
		$.cookie \post-autosave text, { path: '/', expires: 365 }

	$ '#timeline .load-more' .click ->
		$button = $ @
		$button.attr \disabled yes
		$button.text 'Loading...'
		$.ajax config.api-url + '/status/timeline-webhtml' {
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

	$ '#recommendation-users > .users > .user' .each ->
		$user = $ @
		$user.find \.follow-button .click ->
			$button = $ @
			$button.attr \disabled yes

			if ($user.attr \data-is-following) == \true
				$.ajax config.api-url + '/users/unfollow' {
					type: \delete
					data: { 'user-id': $user.attr \data-user-id }
					data-type: \json
					xhr-fields: {+with-credentials}
				} .done ->
					$button.attr \disabled no
					$button.remove-class \following
					$button.add-class \notFollowing
					$button.text 'フォロー'
					$user.attr \data-is-following \false
				.fail ->
					$button.attr \disabled no
			else
				$.ajax config.api-url + '/users/follow' {
					type: \post
					data: { 'user-id': $user.attr \data-user-id }
					data-type: \json
					xhr-fields: {+with-credentials}
				} .done ->
					$button.attr \disabled no
					$button.remove-class \notFollowing
					$button.add-class \following
					$button.text 'フォロー解除'
					$user.attr \data-is-following \true
				.fail ->
					$button.attr \disabled no
