prelude = require 'prelude-ls'

window.STATUSTIMELINE = {}
	..set-event = ($status) ->
		function check-favorited
			($status.attr \data-is-favorited) == \true
		
		function check-reposted
			($status.attr \data-is-reposted) == \true
			
		status-id = $status.attr \data-id
		user-screen-name = $status.attr \data-user-screen-name
		user-name = $status.attr \data-user-name
		text = $status.attr \data-text
		
		$status
			# Init reply button
			..find 'article > .article-main > .main > .footer > .actions > .reply > .reply-button' .click ->
				text = window.prompt "#{user-name}「#{text}」への返信" "@#{user-screen-name} "
				if text? and text != ''
					$.ajax config.api-url + '/status/update' {
						type: \post
						data: {
							text
							'in-reply-to-status-id': status-id
						}
						data-type: \json
						xhr-fields: {+with-credentials}}
					.done (data) ->
						#
					.fail (data) ->
						error-code = JSON.parse data.response-text .error.code
						switch error-code
						| \empty-text => window.alert 'テキストを入力してください。'
						| \too-long-text => window.alert 'テキストが長過ぎます。'
						| \duplicate-content => window.alert '投稿が重複しています。'
						| \failed-attach-image => window.alert '画像の添付に失敗しました。Misskeyが対応していない形式か、ファイルが壊れているかもしれません。'
						| _ => window.alert "不明なエラー (#error-code)"
				
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