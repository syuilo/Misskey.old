prelude = require 'prelude-ls'


window.STATUSTIMELINE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true
		
		function check-reposted
			($status.attr \data-is-reposted) == \true
		
		function activate-display-state
			animation-speed = 200ms
			if ($status.attr \data-display-html-is-active) == \false
				reply-form-text = $status.children \article .find '.article-main > .form-and-replies .reply-form textarea' .val!
				$ '.timeline > .statuses > .status > .status.article' .each ->
					$ @
						..attr \data-display-html-is-active \false
						..remove-class \display-html-active-status-prev
						..remove-class \display-html-active-status-next
				$ '.timeline > .statuses > .status > .status.article > article > .article-main > .talk > i' .each ->
					$ @ .show animation-speed
				$ '.timeline > .statuses > .status > .status.article > article > .article-main > .reply-info' .each ->
					$ @ .show animation-speed
				$ '.timeline > .statuses > .status > .status.article > article > .article-main > .talk > .statuses' .each ->
					$ @ .hide animation-speed
				$ '.timeline > .statuses > .status > .status.article > article > .article-main > .form-and-replies' .each ->
					$ @ .hide animation-speed
				$status
					..attr \data-display-html-is-active \true
					..parent!.prev!.find '.status.article' .add-class \display-html-active-status-prev
					..parent!.next!.find '.status.article' .add-class \display-html-active-status-next
					..children \article .find  '.article-main > .talk > i' .hide animation-speed
					..children \article .find  '.article-main > .talk > .statuses' .show animation-speed
					..children \article .find  '.article-main > .reply-info' .hide animation-speed
					..children \article .find  '.article-main > .form-and-replies' .show animation-speed
					..children \article .find  '.article-main > .form-and-replies .reply-form textarea' .val ''
					..children \article .find  '.article-main > .form-and-replies .reply-form textarea' .focus! .val reply-form-text
			else
				$status
					..attr \data-display-html-is-active \false
					..parent!.prev!.find '.status.article' .remove-class \display-html-active-status-prev
					..parent!.next!.find '.status.article' .remove-class \display-html-active-status-next
					..children \article .find  '.article-main > .talk > i' .show animation-speed
					..children \article .find  '.article-main > .talk > .statuses' .hide animation-speed
					..children \article .find  '.article-main > .reply-info' .show animation-speed
					..children \article .find  '.article-main > .form-and-replies' .hide animation-speed
		
		$status
			# Click event
			..click (event) ->
				can-event = ! (((<[ input textarea button i time a ]>
					|> prelude.map (element) -> $ event.target .is element)
					.index-of yes) >= 0)
				
				if document.get-selection!.to-string! != ''
					can-event = no
				
				if $ event.target .closest \.repost-form .length > 0
					can-event = no
					
				if can-event
					activate-display-state!
			
			# Set display talk window event 
			..find '.main .icon-anchor' .click ->
				window-id = "misskey-window-talk-#{$status.attr \data-user-id}"
				url = $status.find '.main .icon-anchor' .attr \href
				$content = $ '<iframe>' .attr {src: url, +seamless}
				window.open-window do
					window-id
					$content
					"<i class=\"fa fa-comments\"></i>#{$status.find \.user-name .text!}"
					360px
					540px
					yes
					url
				false

			# Ajax setting of reply-form
			..find \.reply-form .submit (event) ->
				event.prevent-default!
				$form = $ @
				$submit-button = $form.find \.submit-button
					..attr \disabled on
				$.ajax "#{config.api-url}/web/status/reply.plain" {
					type: \post
					data: new FormData $form.0
					-processData
					-contentType
					data-type: \text
					xhr-fields: {+with-credentials}}
				.done (html) ->
					$reply = $ html
					$submit-button.attr \disabled off
					$reply.append-to $status.find '.replies > .statuses'
					$i = $ '<i class="fa fa-ellipsis-v reply-info" style="display: none;"></i>'
					$i.append-to $status.find '.article-main'
					$form.remove!
					window.display-message '返信しました！'
				.fail ->
					$submit-button.attr \disabled off

			# Preview attache image
			..find '.image-attacher input[name=image]' .change ->
				$input = $ @
				file = $input.prop \files .0
				if file.type.match 'image.*'
					reader = new FileReader!
						..onload = ->
							$img = $ '<img>' .attr \src reader.result
							$input.parent '.image-attacher' .find 'p, img' .remove!
							$input.parent '.image-attacher' .append $img
						..readAsDataURL file

			## Init tag input of reply-form
			#..find '.reply-form .tag'
			#	.tagit {placeholder-text: 'タグ', field-name: 'tags[]'}
			
			# Init favorite button
			..find 'article > .article-main > .footer > .actions > .favorite > .favorite-button' .click ->
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
			
			# Init reply button
			..find 'article > .article-main > .footer > .actions > .reply > .reply-button' .click ->
				activate-display-state!
			
			# Init repost button
			..find 'article > .article-main > .footer > .actions > .repost > .repost-button' .click ->
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
					$status.find '.repost-form .background' .css \display \block
					$status.find '.repost-form .background' .animate {
						opacity: 1
					} 100ms \linear
					$status.find '.repost-form .form' .css \display \block
					$status.find '.repost-form .form' .animate {
						opacity: 1
					} 100ms \linear
			
			# Init repost form
			..find '.repost-form > .form' .submit (event) ->
				event.prevent-default!
				$form = $ @
				$submit-button = $form.find \.accept
					..attr \disabled on
				$status.attr \data-is-reposted \true
				$.ajax "#{config.api-url}/status/repost" {
					type: \post
					data:
						'status-id': $status.attr \data-id
						text: $status.find '.repost-form > form > .comment-form > input[name=text]' .val!
					data-type: \json
					xhr-fields: {+withCredentials}}
				.done ->
					$submit-button.attr \disabled off
					window.display-message 'Reposted!'
					$status.find '.repost-form .background' .animate {
						opacity: 0
					} 100ms \linear -> $status.find '.repost-form .background' .css \display \none
					$status.find '.repost-form .form' .animate {
						opacity: 0
					} 100ms \linear -> $status.find '.repost-form .form' .css \display \none
				.fail ->
					$submit-button.attr \disabled off
					$status.attr \data-is-reposted \false
					window.display-message 'Repostに失敗しました。再度お試しください。'
			..find '.repost-form > .form > .actions > .cancel' .click ->
				$status.find '.repost-form .background' .animate {
					opacity: 0
				} 100ms \linear -> $status.find '.repost-form .background' .css \display \none
				$status.find '.repost-form .form' .animate {
					opacity: 0
				} 100ms \linear -> $status.find '.repost-form .form' .css \display \none
			..find '.repost-form .background' .click ->
				$status.find '.repost-form .background' .animate {
					opacity: 0
				} 100ms \linear -> $status.find '.repost-form .background' .css \display \none
				$status.find '.repost-form .form' .animate {
					opacity: 0
				} 100ms \linear -> $status.find '.repost-form .form' .css \display \none

function add-status($status)
	new Audio '/resources/sounds/pop.mp3' .play!
		
	$status = $ '<li class="status">' .append($status).hide!
	$recent-status = ($ ($ '#timeline .timeline > .statuses > .status')[0]) .children \.status
	if ($recent-status.attr \data-display-html-is-active) == \true
		$status.children \.status .add-class \display-html-active-status-prev
	window.STATUSTIMELINE.set-event $status.children '.status.article'
	$status.prepend-to ($ '#timeline .timeline > .statuses') .show 200
	
	# Attach Wave effects 
	init-waves-effects!

$ ->
	try
		Notification.request-permission!
	catch
		console.log 'oops'
	
	$ '.timeline .statuses .status .status.article' .each ->
		window.STATUSTIMELINE.set-event $ @
	
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
			icon: status.user-icon-image-url
		}
		n.onshow = ->
			set-timeout ->
				n.close!
			, 10000ms
		n.onclick = ->
			window.open "#{conf.url}/#{sn}/status/#{id}"

	socket.on \talk-message (message) ->
		console.log \talk-message message
		window-id = 'misskey-window-talk-' + message.user.id
		if $('#' + window-id).0
			return
		n = new Notification message.user.name, {
			body: message.text,
			icon: message.user.icon-image-url
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
			$.remove-cookie \post-autosave {path: '/'}
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
			| \denied-gif-upload => window.display-message 'GIFを投稿可能なのはplus-accountのみです。'
			| _ => window.display-message "不明なエラー (#error-code)"
	
	$ '#post-form textarea' .bind \input ->
		text = $ '#post-form textarea' .val!

		# オートセーブ
		$.cookie \post-autosave text, { path: '/', expires: 365 }
		
	# Read more
	$ window .scroll ->
		me = $ @
		current = $ window .scroll-top! + window.inner-height
		if current > $ document .height! - 50
			if not me.data \loading
				me.data \loading yes
				$.ajax config.api-url + '/web/status/timeline-homehtml' {
					type: \get
					data: {
						'max-cursor': $ '#timeline .timeline > .statuses > .status:last-child > .status.article' .attr \data-timeline-cursor
					}
					data-type: \json
					xhr-fields: {+with-credentials}}
				.done (data) ->
					me.data \loading no
					$statuses = $ data
					$statuses.each ->
						$status = $ '<li class="status">' .append $ @
						window.STATUSTIMELINE.set-event $status.children '.status.article'
						$status.append-to $ '#timeline .timeline > .statuses'
					# Attach Wave effects 
					init-waves-effects!
				.fail (data) ->
					me.data \loading no

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
