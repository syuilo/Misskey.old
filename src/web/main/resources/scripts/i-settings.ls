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
