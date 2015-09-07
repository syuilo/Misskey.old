prelude = require 'prelude-ls'

window.STATUS_CORE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true

		function check-reposted
			($status.attr \data-is-reposted) == \true

		function check-pinned
			($status.attr \data-is-pinned) == \true

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

			# Images
			..find '.main .attached-images > .images > .image' .each ->
				$image = $ @
				$img = $image.find \img
				$button = $image.find \button
				$back = $image.find \.background

				$img.click ->
					if ($image.attr \data-is-expanded) == \true
						$image.attr \data-is-expanded \false
						$back.animate {
							opacity: 0
						} 100ms \linear ->
							$back.css \display \none
				$back.click ->
					if ($image.attr \data-is-expanded) == \true
						$image.attr \data-is-expanded \false
						$back.animate {
							opacity: 0
						} 100ms \linear ->
							$back.css \display \none
				$button.click ->
					if ($image.attr \data-is-expanded) == \true
						$image.attr \data-is-expanded \false
						$back.animate {
							opacity: 0
						} 100ms \linear ->
							$back.css \display \none
					else
						$image.attr \data-is-expanded \true
						$back.css \display \block
						$back.animate {
							opacity: 1
						} 100ms \linear

			# Init stargazer tooltips
			..find '.main .stargazers > .stargazers > .stargazer > a' .each ->
				$stargazer = $ @
				$tooltip = $ '<p class="ui-tooltip">' .text $stargazer.attr \data-tooltip
				$stargazer.hover do
					->
						$tooltip.css \bottom $stargazer.outer-height! + 4px
						$stargazer.append $tooltip
						$stargazer.find \.ui-tooltip .css \left ($stargazer.outer-width! / 2) - ($tooltip.outer-width! / 2)
					->
						$stargazer.find \.ui-tooltip .remove!

			# Display profile
			..find 'article > .main > .main > .header > .icon-area > .icon-anchor' .hover do
				->
					$status.user-profile-show-timer = set-timeout ->
						$popup = $ '<iframe class="user-profile-popup">' .attr {
							src: $status.attr \data-user-profile-widget-url
							+seamless
						}
						$popup.css {
							top: 0
							left: $status.find 'article > .main > .main > .header > .icon-area > .icon-anchor' .outer-width! + 32px
						}
						$status.append $popup
					, 500ms
				->
					$status.children \.user-profile-popup .remove!
					clear-timeout $status.user-profile-show-timer

			# Enable reply button
			..find '.reply-form textarea' .bind \input ->
				$status.find '.reply-form .submit-button' .attr \disabled no

			# Ajax setting of reply-form
			..find \.reply-form .submit (event) ->
				event.prevent-default!
				$form = $ @
				$submit-button = $form.find \.submit-button
					..attr \disabled on
				$.ajax "#{config.api-url}/web/status/reply-detail.plain" {
					type: \post
					data: new FormData $form.0
					-processData
					-contentType
					data-type: \text
					xhr-fields: {+with-credentials}}
				.done (html) ->
					$reply = $ html
					$submit-button.attr \disabled off
					$reply.prepend-to $status.find '.replies > .statuses'
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
							$input.parents '.main' .find '.image-preview' .find 'img' .remove!
							$input.parents '.main' .find '.image-preview' .append $img
						..readAsDataURL file

			## Init tag input of reply-form
			#..find '.reply-form .tag'
			#	.tagit {placeholder-text: 'タグ', field-name: 'tags[]'}

			# Init read talk button
			..find 'article > .main > .read-talk' .click ->
				$button = $ @
					..attr \disabled on
					..attr \title '読み込み中...'
					..find \i .attr \class 'fa fa-spinner fa-pulse'

				$.ajax config.api-url + '/web/status/get-talk-detail-html.plain' {
					type: \get
					data: {
						'status-id': $status.find 'article > .main > .reply-source' .attr \data-id
					}
					data-type: \text
					xhr-fields: {+with-credentials}}
				.done (data) ->
					$button.remove!
					$statuses = $ data
					$statuses.each ->
						$talk-status = $ @
						window.STATUS_CORE.set-event $talk-status.children '.status.article'
						$talk-status.append-to $status.find 'article > .main > .talk > .statuses'
				.fail (data) ->
					$button = $ @
						..attr \disabled off
						..attr \title '会話をもっと読む'
						..find \i .attr \class 'fa fa-ellipsis-v'

					window.display-message '読み込みに失敗しました。再度お試しください。'

			# Init pin button
			..find 'article > .main > .main > .footer > .actions > .pin > .pin-button' .click ->
				$button = $ @
					..attr \disabled on
				if check-pinned!
					$status.attr \data-is-pinned \false
					$.ajax "#{config.api-url}/account/delete-pinned-status" {
						type: \delete
						data: {}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-pinned \true
				else
					$status.attr \data-is-pinned \true
					$.ajax "#{config.api-url}/account/update-pinned-status" {
						type: \put
						data: {'status-id': $status.attr \data-id}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done ->
						$button.attr \disabled off
					.fail ->
						$button.attr \disabled off
						$status.attr \data-is-pinned \false

			# Init favorite button
			..find 'article > .main > .main > .footer > .actions > .favorite > .favorite-button' .click ->
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
			..find 'article > .main > .main > .footer > .actions > .reply > .reply-button' .click ->
				activate-display-state!

			# Init repost button
			..find 'article > .main > .main > .footer > .actions > .repost > .repost-button' .click ->
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
					..attr \data-reposting \true
				$status.attr \data-is-reposted \true
				$.ajax "#{config.api-url}/status/repost" {
					type: \post
					data:
						'status-id': $status.attr \data-id
						text: $status.find '.repost-form > form > .comment-form > input[name=text]' .val!
					data-type: \json
					xhr-fields: {+withCredentials}}
				.done ->
					$submit-button
						..attr \disabled off
						..attr \data-reposting \false
					window.display-message 'Reposted!'
					$status.find '.repost-form .background' .animate {
						opacity: 0
					} 100ms \linear -> $status.find '.repost-form .background' .css \display \none
					$status.find '.repost-form .form' .animate {
						opacity: 0
					} 100ms \linear -> $status.find '.repost-form .form' .css \display \none
				.fail ->
					$submit-button
						..attr \disabled off
						..attr \data-reposting \false
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

	..add-status = ($status) ->
		new Audio '/resources/sounds/pop.mp3' .play!

		$status = $ '<li class="status">' .append($status).hide!
		$recent-status = ($ ($ '#timeline .timeline > .statuses > .status')[0]) .children \.status
		if ($recent-status.attr \data-display-html-is-active) == \true
			$status.children \.status .add-class \display-html-active-status-prev
		window.STATUS_CORE.set-event $status.children '.status.article'
		$status.prepend-to ($ '#timeline .timeline > .statuses') .show 200
