$ ->
	SYUILOUI.Tab $ '#nav > ul'

	$ \#profile-form .submit (event) ->
		event.prevent-default!
		$form = $ @
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled on
		$submit-button.attr \value '保存中...'

		$.ajax "#{config.api-url}/account/update" {
			type: \put
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$submit-button.attr \value '保存しました'
			$submit-button.attr \disabled off
		.fail (data) ->
			$submit-button.attr \disabled off

	$ \#user-color-form .submit (event) ->
		event.prevent-default!
		$form = $ @
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled on
		$submit-button.attr \value '保存中...'

		$.ajax "#{config.api-url}/account/update-color" {
			type: \put
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$submit-button.attr \value '保存しました'
			$submit-button.attr \disabled off
		.fail (data) ->
			$submit-button.attr \disabled off

	$ \#wallpaper-form .submit (event) ->
		event.prevent-default!
		$form = $ @
		$submit-button = $form.find '[type=submit]'
		$progress = $form.find \.progress
		$progress-bar = $form.find \progress
		$progress-status = $form.find '.progress .status .text'

		$progress.css \display \block
		$submit-button.attr \disabled on
		$submit-button.attr \value '更新中...'
		$.ajax config.api-url + '/account/update-wallpaper' {
			+async
			type: \put
			-process-data
			-content-type
			data: new FormData $form.0
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
							$progress-status .text "いろいろと処理しています... しばらくお待ちください"
						else
							$progress-bar
								..attr \max e.total
								..attr \value e.loaded
							$progress-status .text "アップロードしています... #{percentage}%"
					, false
				XHR
		}
		.done (data) ->
			location.reload!
		.fail (data) ->
			window.display-message '更新に失敗しました。'
			$submit-button.attr \disabled off
			$submit-button.attr \value 'アップデート'

	$ '#apps > .app' .each ->
		$app = $ @

		$app.find \.remove .click ->
			$submit-button = $ @

			$submit-button.attr \disabled on
			$submit-button.text 'アンインストール中...'

			fd = new FormData!
			fd.append \app-id $app.attr \data-app-id

			$.ajax "#{config.api-url}/account/remove-app" {
				type: \delete
				-process-data
				-content-type
				data: fd
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done (data) ->
				$app.remove!
			.fail (data) ->
				$submit-button.attr \disabled off
				$submit-button.text '再度お試しください'
