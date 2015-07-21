prelude = require 'prelude-ls'

window.STATUSTIMELINE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true
		
		function check-reposted
			($status.attr \data-is-reposted) == \true
			
		user-name = $status.attr \data-user-name
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
				if window.confirm "#{user-name}「#{text}」\nを Repost しますか？"
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