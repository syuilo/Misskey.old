$ ->
	$ '#form' .submit (event) ->
		event.prevent-default!
		$form = $ @
		
		$submit-button = $form.find '[type=submit]'
			..attr \disabled on

		$.ajax "#{config.api-url}/application/create" {
			type: \post
			data: $form.serialize!
			data-type: \json
			xhr-fields: {+withCredentials}}
		.done (data) ->
			location.href = "/app/#{data.id}"
		.fail ->
			$submit-button.attr \disabled off