prelude = require 'prelude-ls'

$ ->
	is-me = $ \html .attr \data-is-me

	# Init edit forms
	if is-me
		init-icon-edit-form!
		init-header-image-edit-form!

	function check-follow
		($ \html .attr \data-is-following) == \true

	if is-me
		$ \#name .click ->
			$ 'main > header' .attr \data-name-editing \true

	$ \#screen-name .click ->
		element= document.get-element-by-id \screen-name
		rng = document.create-range!
		rng.select-node-contents element
		window.get-selection!.add-range rng

	$ '#friend-button' .hover do
		->
			if check-follow!
				$ '#friend-button' .add-class \danger
				$ '#friend-button' .text 'フォロー解除'
		->
			if check-follow!
				$ '#friend-button' .remove-class \danger
				$ '#friend-button' .text 'フォロー中'

	$ '#friend-button' .click ->
		$button = $ @
			..attr \disabled on
		if check-follow!
			$.ajax "#{config.api-url}/users/unfollow" {
				type: \delete
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done ->
				$button .remove-class \danger
				$button
					..attr \disabled off
					..remove-class \following
					..add-class \notFollowing
					..text 'フォロー'
				$ \html .attr \data-is-following \false
			.fail ->
				$button.attr \disabled off
		else
			$.ajax "#{config.api-url}/users/follow" {
				type: \post
				data: {'user-id': $ \html .attr \data-user-id}
				data-type: \json
				xhr-fields: {+with-credentials}}
			.done ->
				$button
					..attr \disabled off
					..remove-class \notFollowing
					..add-class \following
					..text 'フォロー中'
				$ \html .attr \data-is-following \true
			.fail ->
				$button.attr \disabled off

	$ window .scroll ->
		top = $ @ .scroll-top!
		height = parse-int($ \#header-data .css \height)
		pos = 50 - ((top / height) * 50)
		$ \#header-data .css \background-position "center #{pos}%"

function init-icon-edit-form
	$form = $ \#icon-edit-form
	$submit-button = $form.find '[type=submit]'

	$ \#icon .click ->
		$ \#icon-edit-form-back .css \display \block
		$ \#icon-edit-form-back .animate {
			opacity: 1
		} 500ms \linear
		$ \#icon-edit-form .css \visibility \visible
		$ \#icon-edit-form .animate {
			top: 0
			opacity: 1
		} 1000ms \easeOutElastic

	$form.find \.cancel .click ->
		$ \#icon-edit-form-back .animate {
			opacity: 0
		} 500ms \linear ->
			$ \#icon-edit-form-back .css \display \none
		$ \#icon-edit-form .animate {
			top: '-100%'
			opacity: 0
		} 1000ms \easeInOutQuart ->
			$ \#icon-edit-form .css \visibility \hidden

	$form.submit (event) ->
		event.prevent-default!
		$submit-button.attr \disabled yes
		$submit-button.attr \value '更新しています...'
		$.ajax config.api-url + '/account/update-icon' {
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
			$submit-button.attr \value '更新 \uf1d8'

	$form.find 'input[name=image]' .change ->
		$input = $ @
		file = $input.prop \files .0
		if file.type.match 'image.*'
			reader = new FileReader!
				..onload = ->
					$submit-button.attr \disabled no
					$ '#icon-edit-form .preview > .image' .attr \src reader.result
					$ '#icon-edit-form .preview > .image' .cropper {
						aspect-ratio: 1 / 1
						crop: (data) ->
							$ '#icon-edit-form input[name=trim-x]' .val Math.round data.x
							$ '#icon-edit-form input[name=trim-y]' .val Math.round data.y
							$ '#icon-edit-form input[name=trim-w]' .val Math.round data.width
							$ '#icon-edit-form input[name=trim-h]' .val Math.round data.height
					}
				..read-as-dataURL file

function init-header-image-edit-form
	$form = $ \#header-image-edit-form
	$submit-button = $form.find '[type=submit]'

	$ \#header-image-edit-button .click ->
		$ \#header-image-edit-form-back .css \display \block
		$ \#header-image-edit-form-back .animate {
			opacity: 1
		} 500ms \linear
		$ \#header-image-edit-form .css \visibility \visible
		$ \#header-image-edit-form .animate {
			top: 0
			opacity: 1
		} 1000ms \easeOutElastic

	$form.find \.cancel .click ->
		$ \#header-image-edit-form-back .animate {
			opacity: 0
		} 500ms \linear ->
			$ \#header-image-edit-form-back .css \display \none
		$ \#header-image-edit-form .animate {
			top: '-100%'
			opacity: 0
		} 1000ms \easeInOutQuart ->
			$ \#header-image-edit-form .css \visibility \hidden

	$form.submit (event) ->
		event.prevent-default!
		$submit-button.attr \disabled yes
		$submit-button.attr \value '更新しています...'
		$.ajax config.api-url + '/account/update-banner' {
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
			$submit-button.attr \value '更新 \uf1d8'

	$form.find 'input[name=image]' .change ->
		$input = $ @
		file = $input.prop \files .0
		if file.type.match 'image.*'
			reader = new FileReader!
				..onload = ->
					$submit-button.attr \disabled no
					$ '#header-image-edit-form .preview > .image' .attr \src reader.result
					$ '#header-image-edit-form .preview > .image' .cropper {
						aspect-ratio: 16 / 9
						crop: (data) ->
							$ '#header-image-edit-form input[name=trim-x]' .val Math.round data.x
							$ '#header-image-edit-form input[name=trim-y]' .val Math.round data.y
							$ '#header-image-edit-form input[name=trim-w]' .val Math.round data.width
							$ '#header-image-edit-form input[name=trim-h]' .val Math.round data.height
					}
				..read-as-dataURL file
