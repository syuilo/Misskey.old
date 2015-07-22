$ ->	
	$ \#form .submit (event) ->
		event.prevent-default!

		$form = $ @
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.attr \value 'Updating...'

		$.ajax config.api-url + '/account/update-mobile-header-design' {
			type: \put
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			location.reload!
		.fail (data) ->
			$submit-button.attr \disabled no
			$submit-button.attr \value '失敗'
