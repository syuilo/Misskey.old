function swing($elem, force)
	t = 1
	timer = set-interval update, 10ms
	function update
		t++
		pos = ((Math.sin(t / 20) * force) / ((t / 512) / 3))
		$elem.css \transform "perspective(1024px) rotateX(#{pos}deg)"

$ ->
	function set-features1-design-layer
		$ '#features-1 > .design-layer' .css \height "#{$ \#features-1 .outer-height! + 128}px"
	
	function set-footer-design-layer
		$ '#footer > .design-layer' .css \height "#{$ \#footer .outer-height! + 128}px"
	
	set-features1-design-layer!
	set-footer-design-layer!
	
	$ window .resize ->
		set-features1-design-layer!
		set-footer-design-layer!

	$ '#login-form' .submit (event) ->
		event.prevent-default!
		$form = $ @
			..css {
				'transform': 'perspective(512px) rotateX(-90deg)'
				'opacity': '0'
				'transition': 'all ease-in 0.5s'
			}
		
		$submit-button = $form.find '[type=submit]'
			..attr \disabled on

		$.ajax \/login {
			type: \post
			data: $form.serialize!}
		.done ->
			location.reload!
		.fail ->
			$submit-button.attr \disabled off
			set-timeout ->
				$form.css {
					'transform': 'perspective(512px) scale(1)'
					'opacity': '1'
					'transition': 'all ease 0.7s'
				}
			, 500ms

	$ '#new' .click show-register-form
	init-register-form!

function init-register-form
	$progress = $ '#register-form progress'
	user-name-input-query = '#register-form .user-name .user-name-input'
	nickname-input-query = '#register-form .nickname .nickname-input'
	password-input-query = '#register-form .password .password-input'
	password-retype-input-query = '#register-form .password-retype .password-retype-input'
	user-color-input-query = '#register-form .user-color .user-color-input'

	init-user-name-section!
	init-nickname-section!
	init-password-section!
	init-password-retype-section!
	init-user-color-section!

	$ '#register-form form' .submit (event) ->
		event.prevent-default!
		$form = $ @

		$.ajax "#{config.api-url}/account/create" {
			type: \post
			data: $form.serialize!
			data-type: \json
			xhr-fields: {+withCredentials}}
		.done ->
			location.href = config.url
		.fail ->
	
	$ '#register-cancel' .click (event) ->
		hide-register-form!

	function init-user-name-section
		$column = $ '#register-form .user-name'
		$input = $ user-name-input-query
		right = no
		
		$input .focus ->
			$cursor = $ \#register-form-cursor
			top = ($column.position!.top) + ($column.outer-height! / 2) - ($cursor.outer-height! / 2) + ($ '#register-form form' .scroll-top!)
			$cursor .animate {
				top: "#{top}px"
			} 1000ms \easeOutElastic

		$input .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$input .keyup ->
			right = no
			hide-message!
			sn = $input .val!
			
			$ '.profile-page-url-preview' .text "https://misskey.xyz/#sn"

			if sn != ''
				err = switch
					| not sn.match /^[a-zA-Z0-9_]+$/ => '半角英数記号(_)のみでお願いしますっ'
					| sn.length < 4chars             => '4文字以上でお願いしますっ'
					| sn.match /^[0-9]+$/            => 'すべてを数字にすることはできませんっ'
					| sn.length > 20chars            => '20文字以内でお願いします'
					| _                              => null

				if err
					show-message err, no
				else
					show-message '確認中...' null
					$.ajax "#{config.api-url}/screenname-available" {
						type: \get
						data: {'screen-name': sn}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done (result) ->
						if result
							right = no
							show-message 'このIDは既に使用されていますっ' no
						else
							right = yes
							show-message 'このIDは使用できますっ！' yes
					.fail ->
						show-message '確認に失敗しました;;' null

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"user-name-available\" class=\"message #{klass}\">#{message}</p>"
			$message.append-to '#register-form .user-name' .animate {
				'margin-top': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#user-name-available' .remove!

	function init-nickname-section
		$input = $ nickname-input-query
		$column = $ '#register-form .nickname'
		right = no
		
		$input .focus ->
			$cursor = $ \#register-form-cursor
			top = ($column.position!.top) + ($column.outer-height! / 2) - ($cursor.outer-height! / 2) + ($ '#register-form form' .scroll-top!)
			$cursor .animate {
				top: "#{top}px"
			} 1000ms \easeOutElastic
			
		$input .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$input .keyup ->
			right = no
			hide-message!
			name = $input .val!
			if name.length > 0chars
				right = yes
				show-message 'Great!' yes

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"nicknameAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.append-to '#register-form .nickname' .animate {
				'margin-top': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#nicknameAvailable' .remove!

	function init-password-section
		$input = $ password-input-query
		$column = $ '#register-form .password'
		right = no
		
		$input .focus ->
			$cursor = $ \#register-form-cursor
			top = ($column.position!.top) + ($column.outer-height! / 2) - ($cursor.outer-height! / 2) + ($ '#register-form form' .scroll-top!)
			$cursor .animate {
				top: "#{top}px"
			} 1000ms \easeOutElastic
		
		$input .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$input .keyup ->
			right = no
			hide-message!
			password = $input .val!
			if password.length > 0
				err = switch
					| password.length < 8chars => '8文字以上でお願いします'
					| _ => null
				if err
					show-message err, no
				else
					show-message 'Nice!' yes
					right = yes
			else
				false

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"passwordAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.append-to '#register-form .password' .animate {
				'margin-top': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#passwordAvailable' .remove!

	function init-password-retype-section
		$input = $ password-retype-input-query
		$column = $ '#register-form .password-retype'
		right = no
		
		$input .focus ->
			$cursor = $ \#register-form-cursor
			top = ($column.position!.top) + ($column.outer-height! / 2) - ($cursor.outer-height! / 2) + ($ '#register-form form' .scroll-top!)
			$cursor .animate {
				top: "#{top}px"
			} 1000ms \easeOutElastic
		
		$input .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$input .keyup ->
			right = no
			hide-message!
			password = $ password-input-query .val!
			password-retype = $input .val!
			if password-retype.length > 0chars
				if password-retype != password
					show-message '一致していませんっ！' no
					false
				else
					right = yes
					show-message 'Okay!' yes
			else
				false

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"passwordRetypeAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.append-to '#register-form .password-retype' .animate {
				'margin-top': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#passwordRetypeAvailable' .remove!

	function init-user-color-section
		right = no

		$ user-color-input-query .change ->
			hide-message!
			color = $ user-color-input-query .val!
			right = yes
			show-message 'Good!' yes

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"userColorAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.append-to '#register-form .user-color' .animate {
				'margin-top': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#userColorAvailable' .remove!

function show-register-form
	$ \#register-form-background .css \display \block
	$ \#register-form-background .animate {
		opacity: 1
	} 500ms \linear
	$ \#register-form .animate {
		top: 0
		opacity: 1
	} 1000ms \easeOutElastic
	$ '#register-form progress' .attr \value 1
	$ '#register-form .user-name .user-name-input' .focus!

function hide-register-form
	$ \#register-form-background .animate {
		opacity: 0
	} 500ms \linear ->
		$ \#register-form-background .css \display \none
	$ \#register-form .animate {
		top: '-200%'
		opacity: 0
	} 1000ms \easeInOutQuart