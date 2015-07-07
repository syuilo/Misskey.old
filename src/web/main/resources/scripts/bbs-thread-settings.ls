$ ->
	$form = $ \#form
	
	$form .find '.image-attacher input[name=image]' .change ->
		$input = $ @
		file = $input.prop(\files).0
		if file.type.match 'image.*'
			reader = new FileReader!
			reader.onload = ->
				$img = $ '<img>' .attr \src reader.result
				$input.parent '.image-attacher' .find 'p, img' .remove!
				$input.parent '.image-attacher' .append $img
			reader.read-as-dataURL file
	
	$form .submit (event) ->
		event.prevent-default!
		
		$submit-button = $form.find '[type=submit]'

		$submit-button.attr \disabled yes
		$submit-button.attr \value '更新しています...'

		$.ajax config.api-url + '/bbs/thread/update' {
			type: \put
			-process-data
			-content-type
			data: new FormData $form.0
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			location.href = "/bbs/thread/#{data.id}"
		.fail (data) ->
			$submit-button.attr \disabled no
			$submit-button.attr \value '更新 \uf1d8'
