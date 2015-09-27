window.music-center-open = no

function update-statuses
	$.ajax "#{config.api-url}/web/get-header-statuses" {
		type: \get
		data-type: \json
		xhr-fields: {+with-credentials}}
	.done (result) ->
		unread-notices-count = result.unread-notices-count
		unread-talk-messages-count = result.unread-talk-messages-count

		if $ '#misskey-main-header .notices .unread-count' .0
			$ '#misskey-main-header .notices .unread-count' .remove!
		if unread-notices-count != 0
			$ '#misskey-main-header .notices .dropdown .dropdown-header p' .append do
				$ '<span class="unread-count">' .text unread-notices-count

		if $ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount' .0
			$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount' .remove!
		if unread-talk-messages-count != 0
			$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a' .append do
				$ '<span class="unreadCount">' .text unread-talk-messages-count
	.fail ->

function update-clock
	s = (new Date!).get-seconds!
	m = (new Date!).get-minutes!
	h = (new Date!).get-hours!
	yyyymmdd = moment!.format 'YYYY/MM/DD'
	yyyymmdd = "<span class='yyyymmdd'>#yyyymmdd</span>"
	hhmm = moment!.format 'HH:mm'
	if s % 2 == 0
		hhmm .= replace \: '<span style=\'visibility:visible\'>:</span>'
	else
		hhmm .= replace \: '<span style=\'visibility:hidden\'>:</span>'
	clock = $ '#misskey-main-header .time .now'
	clock.html "#yyyymmdd<br>#hhmm"

	# DRAW CLOCK
	vec2 = (x, y) ->
		@.x = x
		@.y = y

	canvas = document.get-element-by-id \misskey-main-clock-canvas
	ctx = canvas.get-context \2d
	canv-w = canvas.width
	canv-h = canvas.height
	ctx.clear-rect 0, 0, canv-w, canv-h

	# 背景
	center = (Math.min (canv-w / 2), (canv-h / 2))
	line-start = center * 0.90
	line-end-short = center * 0.87
	line-end-long = center * 0.84
	for i from 0 to 59 by 1
		angle = Math.PI * i / 30
		uv = new vec2 (Math.sin angle), (-Math.cos angle)
		ctx.begin-path!
		ctx.line-width = 1
		ctx.move-to do
			(canv-w / 2) + uv.x * line-start
			(canv-h / 2) + uv.y * line-start
		if i % 5 == 0
			ctx.stroke-style = 'rgba(255, 255, 255, 0.2)'
			ctx.line-to do
				(canv-w / 2) + uv.x * line-end-long
				(canv-h / 2) + uv.y * line-end-long
		else
			ctx.stroke-style = 'rgba(255, 255, 255, 0.1)'
			ctx.line-to do
				(canv-w / 2) + uv.x * line-end-short
				(canv-h / 2) + uv.y * line-end-short
		ctx.stroke!

	# 分
	angle = Math.PI * (m + s / 60) / 30
	length = (Math.min canv-w, canv-h) / 2.6
	uv = new vec2 (Math.sin angle), (-Math.cos angle)
	ctx.begin-path!
	ctx.stroke-style = \#ffffff
	ctx.line-width = 2
	ctx.move-to do
		(canv-w / 2) - uv.x * length / 5
		(canv-h / 2) - uv.y * length / 5
	ctx.line-to do
		(canv-w / 2) + uv.x * length
		(canv-h / 2) + uv.y * length
	ctx.stroke!

	# 時
	angle = Math.PI * (h % 12 + m / 60) / 6
	length = (Math.min canv-w, canv-h) / 4
	uv = new vec2 (Math.sin angle), (-Math.cos angle)
	ctx.begin-path!
	#ctx.stroke-style = \#ffffff
	ctx.stroke-style = $ '#misskey-main-header' .attr \data-user-color
	ctx.line-width = 2
	ctx.move-to do
		(canv-w / 2) - uv.x * length / 5
		(canv-h / 2) - uv.y * length / 5
	ctx.line-to do
		(canv-w / 2) + uv.x * length
		(canv-h / 2) + uv.y * length
	ctx.stroke!

	# 秒
	angle = Math.PI * s / 30
	length = (Math.min canv-w, canv-h) / 2.6
	uv = new vec2 (Math.sin angle), (-Math.cos angle)
	ctx.begin-path!
	ctx.stroke-style = 'rgba(255, 255, 255, 0.5)'
	ctx.line-width = 1
	ctx.move-to do
		(canv-w / 2) - uv.x * length / 5
		(canv-h / 2) - uv.y * length / 5
	ctx.line-to do
		(canv-w / 2) + uv.x * length
		(canv-h / 2) + uv.y * length
	ctx.stroke!

$ ->
	update-statuses!
	set-interval update-statuses, 10000ms

	update-clock!
	set-interval update-clock, 1000ms

	$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey' .click ->
		if window.music-center-open
			$ '#misskey-main-header > .informationCenter' .css \height '0'
		else
			$ '#misskey-main-header > .informationCenter' .css \height '200px'
		window.music-center-open = !music-center-open

	$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a' .click ->
		window-id = "misskey-window-talk-histories"
		$content = $ '<iframe>' .attr {src: '/i/talks', +seamless}
		window.open-window do
			window-id
			$content
			"<i class=\"fa fa-comments\"></i>トーク"
			500px
			560px
			yes
			'/i/talks'
		false

	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"
	
	# 「Misskey Menu」ドロップダウン
	$ '#misskey-main-header .misskey-menu .dropdown .dropdown-header' .click ->
		$dropdown = $ '#misskey-main-header .misskey-menu .dropdown'

		function close
			$dropdown.attr \data-active \false

		function open
			$ document .click (e) ->
				if !$.contains $dropdown[0], e.target
					close!
			$dropdown.attr \data-active \true

		if ($dropdown.attr \data-active) == \true
			close!
		else
			open!

	# 「アカウント」ドロップダウン
	$ '#misskey-main-header .account .dropdown .dropdown-header' .click ->
		$dropdown = $ '#misskey-main-header .account .dropdown'

		function close
			$dropdown.attr \data-active \false
			$dropdown.find 'i.fa.fa-angle-up' .attr \class 'fa fa-angle-down'

		function open
			$ document .click (e) ->
				if !$.contains $dropdown[0], e.target
					close!
			$dropdown.attr \data-active \true
			$dropdown.find 'i.fa.fa-angle-down' .attr \class 'fa fa-angle-up'

		if ($dropdown.attr \data-active) == \true
			close!
		else
			open!

	# 通知全削除ﾎﾞﾔﾝ
	$ '#misskey-main-header .notices .delete-all-button' .click ->
		$ '#misskey-main-header .notices .notice' .each (i) ->
			$notice = $ @
			set-timeout ->
				$notice.transition {
					perspective: \4096px
					rotate-x: \90
					opacity: \0
				} 200ms \ease ->
					$message.remove!
			, i * 50

		$.ajax config.api-url + '/notice/delete-all' {
			type: \delete
			data: {}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$ '#misskey-main-header .notices .unread-count' .remove!
			$list = $ '<ol class="notices" />'
			$info = $ '<p class="notice-empty">通知はありません</p>'
			$info.append-to $notices-container
		.fail (data) ->


	# 「通知」ドロップダウン
	$ '#misskey-main-header .notices .dropdown .dropdown-header' .click ->
		$dropdown = $ '#misskey-main-header .notices .dropdown'

		function close
			$dropdown.attr \data-active \false
			$ '#misskey-main-header .notices .dropdown .dropdown-content .main' .empty!

		function open
			$ document .click (e) ->
				if !$.contains $dropdown[0], e.target
					close!
			$dropdown.attr \data-active \true

			$notices-container = $ '#misskey-main-header .notices .dropdown .dropdown-content .main'
			$ '<img class="loading" src="/resources/images/notices-loading.gif" alt="loading..." />' .append-to $notices-container

			# 通知読み込み
			$.ajax config.api-url + '/notice/timeline-webhtml' {
				type: \get
				data: {}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done (data) ->
				$ '#misskey-main-header .notices .loading' .remove!
				$ '#misskey-main-header .notices .unread-count' .remove!
				$list = $ '<ol class="notices" />'
				if data != ''
					$ '#misskey-main-header .notices .nav' .css \display \block
					$ '#misskey-main-header .notices .main' .css \margin-top \32px
					$notices = $ data
					$notices.each ->
						$notice = $ @
						$notice.append-to $list
					$list.append-to $notices-container
				else
					$info = $ '<p class="notice-empty">通知はありません</p>'
					$info.append-to $notices-container
			.fail (data) ->
				$ '#misskey-main-header .notices .loading' .remove!

		if ($dropdown.attr \data-active) == \true
			close!
		else
			open!

	$ '#misskey-main-header .search input' .bind \input ->
		$input = $ @
		$result = $ '#misskey-main-header .search .result'
		if $input .val! == ''
			$input.attr \data-active \false
			$result.empty!
		else
			$input.attr \data-active \true
			$.ajax "#{config.api-url}/search/user" {
				type: \get
				data: {'query': $input .val!}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done (result) ->
				$result.empty!
				if (result.length > 0) && ($input .val! != '')
					$result.append $ '<ol class="users">'
					result.for-each (user) ->
						$result.find \ol .append do
							$ \<li> .append do
								$ '<a class="ui-waves-effect">' .attr {
									'href': "#{config.url}/#{user.screen-name}"
									'title': user.comment}
								.append do
									$ '<img class="icon" alt="icon">' .attr \src user.icon-image-url
								.append do
									$ '<span class="name">' .text user.name
								.append do
									$ '<span class="screen-name">' .text "@#{user.screen-name}"
					window.init-waves-effects!
			.fail ->

	$ \#misskey-post-button .click ->
		$ \#misskey-create-status-form .find \textarea .focus!
		$ \#misskey-create-status-form-back .css \display \block
		$ \#misskey-create-status-form-back .animate {
			opacity: 1
		} 100ms \linear
		$ \#misskey-create-status-form-container .css \display \block
		$ \#misskey-create-status-form .animate {
			opacity: 1
		} 100ms \linear
	$ \#misskey-create-status-form .click (e) ->
		e.stop-propagation!
	$ \#misskey-create-status-form-container .click ->
		$ \#misskey-create-status-form-back .animate {
			opacity: 0
		} 100ms \linear -> $ \#misskey-create-status-form-back .css \display \none
		$ \#misskey-create-status-form .animate {
			opacity: 0
		} 100ms \linear -> $ \#misskey-create-status-form-container .css \display \none
	$ \#misskey-create-status-form .find \.close-button .click ->
		$ \#misskey-create-status-form-back .animate {
			opacity: 0
		} 100ms \linear -> $ \#misskey-create-status-form-back .css \display \none
		$ \#misskey-create-status-form .animate {
			opacity: 0
		} 100ms \linear -> $ \#misskey-create-status-form-container .css \display \none

	$ \#misskey-create-status-form .find \textarea .bind \input ->
		console.log \a
		$ \#misskey-create-status-form .find \.submit-button .attr \disabled off

	$ \#misskey-create-status-form .find '.image-attacher input[name=image]' .change ->
		$input = $ @
		$ \#misskey-create-status-form .find '.image-preview-container' .css \display \block
		$ \#misskey-create-status-form .find \.submit-button .attr \disabled off
		file = $input.prop \files .0
		if file.type.match 'image.*'
			reader = new FileReader!
				..onload = ->
					$img = $ '<img>' .attr \src reader.result
					$ \#misskey-create-status-form .find '.image-preview' .find 'img' .remove!
					$ \#misskey-create-status-form .find '.image-preview' .append $img
				..readAsDataURL file

	$ \#misskey-create-status-form .submit (event) ->
		event.prevent-default!
		$form = $ @
		$submit-button = $form.find '[type=submit]'
		$progress = $form.find \.progress
		$progress-bar = $form.find \progress
		$progress-status = $form.find '.progress .status .text'

		$progress.css \display \block
		$submit-button.attr \disabled on
		$submit-button.attr \value 'Updating'
		$form.find \textarea .attr \disabled on

		fd = new FormData!
		fd.append \text ($form.find \textarea .val!)
		jQuery.each ($form.find 'input[type=file]')[0].files, (i, file) ->
			fd.append \image file

		$.ajax config.api-url + '/status/update' {
			+async
			type: \post
			-process-data
			-content-type
			data: fd
			data-type: \json
			xhr-fields: {+with-credentials}
			xhr: ->
				XHR = $.ajax-settings.xhr!
				if XHR.upload
					XHR.upload.add-event-listener \progress (e) ->
						percentage = Math.floor (parse-int e.loaded / e.total * 10000) / 100
						if percentage == 100
							$progress-bar
								..remove-attr \value
								..remove-attr \max
							$progress-status .text "しばらくお待ちください..."
						else
							$progress-bar
								..attr \max e.total
								..attr \value e.loaded
							$progress-status .text "アップロードしています... #{percentage}%"
					, false
				XHR
		}
		.done (data) ->
			window.display-message '投稿しました！'
			$form[0].reset!
			$submit-button.attr \disabled off
			$form.find \textarea .attr \disabled off
			$progress.css \display \none
			$ \#misskey-create-status-form .find '.image-preview-container' .css \display \none
			$ \#misskey-create-status-form .find '.image-preview' .find 'img' .remove!
			$ \#misskey-create-status-form-back .animate {
				opacity: 0
			} 100ms \linear -> $ \#misskey-create-status-form-back .css \display \none
			$ \#misskey-create-status-form .animate {
				opacity: 0
			} 100ms \linear -> $ \#misskey-create-status-form-container .css \display \none
		.fail (data) ->
			window.display-message '投稿に失敗しました。'
			$submit-button.attr \disabled off
			$form.find \textarea .attr \disabled off
			$progress.css \display \none
			$submit-button.attr \value 'Re Update'


$ window .load ->
	header-height = $ 'body > #misskey-main-header' .outer-height!
	$ \body .css \margin-top "#{header-height}px"
	$ \html .css \background-position "center #{header-height}px"
	$ '[data-ui-background-wallpaper-blur="true"]' .each ->
		$ @ .css \background-position "center #{header-height}px"
