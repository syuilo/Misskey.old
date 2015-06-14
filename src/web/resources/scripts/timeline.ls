prelude = require 'prelude-ls'

window.STATUSTIMELINE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true
		
		function check-reposted
			($status.attr \data-is-reposted) == \true
		
		$status
			# Set display talk window event 
			..children \article .children \a .click ->
				window-id = "misskey-window-talk-#{$status.attr \data-user-id}"
				url = $status.children \article .children \a .attr \href
				$content = $ '<iframe>' .attr {src: url, +seamless}
				open-window do
					window-id
					$content
					"<i class=\"fa fa-comments\"></i>#{$status.children \article .children \header .children \h2 .children \a .text!}"
					300px
					450px
					yes
					url
				false

			# Ajax setting of reply-form
			..find \.reply-form .submit (event) ->
				event.prevent-default!
				$form = $ @
				$submit-button = $form.find \.submit-button
					..attr \disabled on
				$.ajax "#{config.api-url}/status/update" {
					type: \post
					data: new FormData $form.0
					-processData
					-contentType
					data-type: \json
					xhr-fields: {+withCredentials}}
				.done ->
					$submit-button.attr \disabled off
					$form.text '送信しました'
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

			# Init tag input of reply-form
			..find 'article > .article-main > footer .reply-form .tag'
				.tagit {placeholder-text: 'タグ', field-name: 'tags[]'}
			
			# Init favorite button
			..find 'article > .article-main > .main > .footer > .actions > .favorite > .favorite-button' .click ->
				$button = $ @
					..attr \disabled on
				if check-favorited
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
				$button = $ @
					..attr \disabled on
				if check-reposted
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
			
			# Click event
			..click (event) ->
				$clicked-status = $ @
				
				can-event = ! ((<[ input textarea button i time a ]>
					|> prelude.each (element) -> $ event.target .is element)
					.index-of yes) >= 0
				
				if document.get-selection!.to-string! != ''
					can-event = no
					
				can-event = yes
				
				if can-event
					animation-speed = 200ms
					if ($clicked-status.attr \data-display-html-is-active) == \false
						reply-form-text = $clicked-status.find 'article > .article-main > footer .reply-form textarea' .val!
						$clicked-status
							..attr \data-display-html-is-active \true
							..parent!.prev!.find '.status.article' .add-class \display-html-active-status-prev
							..parent!.next!.find '.status.article' .add-class \display-html-active-status-next
							..find 'article > .article-main > .talk > i' .hide animation-speed
							..find 'article > .article-main > .talk > .statuses' .show animation-speed
							..find 'article > .article-main > footer' .show animation-speed
							..find 'article > .article-main > footer .reply-form textarea' .val ''
							..find 'article > .article-main > footer .reply-form textarea' .focus! .val reply-form-text
						$ '.timeline > .statuses > .status > .status.article' .each ->
							$ @
								..attr \data-display-html-is-active \false
								..remove-class \display-html-active-status-prev
								..remove-class \display-html-active-status-next
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > .talk > i' .each ->
							$ @ .show animation-speed
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > .talk > .statuses' .each ->
							$ @ .hide animation-speed
						$ '.timeline > .statuses > .status > .status.article > article > .article-main > footer' .each ->
							$ @ .hide animation-speed
					else
						$clicked-status
							..attr \data-display-html-is-active \false
							..parent!.prev!.find '.status.article' .remove-class \display-html-active-status-prev
							..parent!.next!.find '.status.article' .remove-class \display-html-active-status-next
							..find 'article > .article-main > .talk > i' .show animation-speed
							..find 'article > .article-main > .talk > .statuses' .hide animation-speed
							..find 'article > .article-main > footer' .hide animation-speed

$ ->
	$ '.timeline .statuses .status .status.article' .each ->
		window.STATUSTIMELINE.set-event $ @
