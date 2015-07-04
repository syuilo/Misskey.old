$ ->
	$form = $ \#form
	$form .submit (event) ->
		event.prevent-default!
		
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.attr \value '作成しています...'

		$.ajax config.api-url + '/bbs/thread/create' {
			type: \post
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			location.href = "/bbs/thread/#{data.id}"
		.fail (data) ->
			$submit-button.attr \disabled no
			$submit-button.attr \value 'スレッドを作成する \uf1d8'
