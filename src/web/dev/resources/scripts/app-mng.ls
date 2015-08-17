$ ->
	SYUILOUI.Tab $ '#nav > ul'
	init-icon-edit-form!

function init-icon-edit-form
	$form = $ '#app-icon-edit form'
	$submit-button = $form.find '[type=submit]'

	$form.submit (event) ->
		event.prevent-default!
		$submit-button.attr \disabled yes
		$submit-button.text 'Updating...'
		$.ajax config.api-url + '/application/update-icon' {
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
						$form.find \progress
							..attr \max e.total
							..attr \value e.loaded
						$form.find '.progress .status' .text "アップロードしています... #{percentage}%"
					, false
				XHR
		}
		.done (data) ->
			location.reload!
		.fail (data) ->
			$submit-button.attr \disabled no
			$submit-button.text 'Update'

	$form.find 'input[name=image]' .change ->
		$input = $ @
		file = $input.prop \files .0
		if file.type.match 'image.*'
			reader = new FileReader!
				..onload = ->
					$submit-button.attr \disabled no
					$form.find '.preview > .image' .attr \src reader.result
					$form.find '.preview > .image' .cropper {
						aspect-ratio: 1 / 1
						crop: (data) ->
							$form.find 'input[name=trim-x]' .val Math.round data.x
							$form.find 'input[name=trim-y]' .val Math.round data.y
							$form.find 'input[name=trim-w]' .val Math.round data.width
							$form.find 'input[name=trim-h]' .val Math.round data.height
					}
				..read-as-dataURL file