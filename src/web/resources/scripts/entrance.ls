function swing($elem, force)
	t = 1
	timer = setInterval update, 10ms
	function update
		t++
		pos = ((Math.sin(t / 20) * force) / ((t / 512) / 3))
		$elem.css \transform "perspective(1024px) rotateX(#{pos}deg)"

$ ->
	swing ($ '#loginForm'), 1
	swing ($ '#new'), 2

	$ '#loginForm' .submit (event) ->
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
	$progress = $ '#registerForm progress'
	user-name-input-query = '#registerForm .user-name .user-name-input'
	nickname-input-query = '#registerForm .nickname .nickname-input'
	password-input-query = '#registerForm .password .password-input'
	password-retype-input-query = '#registerForm .password-retype .password-retype-input'
	user-color-input-query = '#registerForm .user-color .user-color-input'

	init-user-name-section!
	init-nickname-section!
	init-password-section!
	init-password-retype-section!
	init-user-color-section!
	init-confirm-section!

	$ '#registerForm form' .submit (event) ->
		event.prevent-default!
		$form = $ @

		$.ajax "#{config.api-url}/account/create" {
			type: \post
			data: $form.serialize!
			data-type: \json
			xhr-fields: {+withCredentials)}
		.done ->
			location.href = config.url
		.fail ->

	function init-user-name-section
		right = no
		
		$cancel-button = $ '#registerForm .user-name button.cancel'
			..click cancel
		$next-button = $ '#registerForm .user-name button.next'
			..click next

		$ user-name-input-query .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ user-name-input-query .keyup ->
			right = no
			$next-button.attr \disabled on
			hide-message!
			sn = $ user-name-input-query .val!

			if not empty sn
				err = switch
					| sn.length < 4chars             => '4文字以上でお願いしますっ'
					| sn.match /^[0-9]+$/            => 'すべてを数字にすることはできませんっ'
					| not sn.match /^[a-zA-Z0-9_]+$/ => '半角英数記号(_)のみでお願いしますっ'
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
							$next-button.attr \disabled off
					.fail ->
						show-message '確認に失敗しました;;' null

		function cancel
			$ '#registerForm .user-name' .animate {
				left: '100%'
				opacity: 0
			} 500ms \easeOutQuint
			$ '#registerForm .user-name .title' .animate {
				left: '64px'
				opacity: 0
			} 1000ms \easeOutQuint
			$ '#registerForm progress' .css \height 0
			$ '#registerForm progress' .attr \value 0

			setTimeout ->
				$ '#registerForm' .css {display: \none}
			, 500ms

		function next
			$progress.attr \value 2

			$ '#registerForm .user-name' .css \transform 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)'
			$ '#registerForm .user-name' .animate {
				opacity: 0.2
			} 500ms \easeOutQuint

			$ '#registerForm .nickname' .animate {
				left: 0
				opacity: 1
			} 1000ms \easeOutElastic
			$ '#registerForm .nickname .title' .animate {
				left: 0
				opacity: 1
			} 2000ms \easeOutElastic
			$ nickname-input-query .focus!

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"userNameAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ user-name-input-query .position!.top - 32px + ($ user-name-input-query .outer-height! / 2))
			$message.append-to '#registerForm .user-name' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#userNameAvailable' .remove!

	function init-nickname-section
		right = no
		$back-button = $ '#registerForm .nickname button.back'
			..click back
		$next-button = $ '#registerForm .nickname button.next'
			..click next
			
		$(nickname-input-query).on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ nickname-input-query .keyup ->
			right = no
			hide-message!
			$next-button.attr \disabled on
			name = $ nickname-input-query .val!
			if name.length > 0chars
				right = yes
				show-message 'Great!' yes
				$next-button.attr \disabled off

		function back
			$progress.attr \value 1

			$ '#registerForm .user-name' .css \transform 'perspective(512px) translateX(0) translateZ(0) rotateY(0)'
			$ '#registerForm .user-name' .animate {
				opacity: 1
			} 500ms \easeOutQuint

			$ '#registerForm .nickname' .animate {
				left: '100%'
				opacity: 0
			} 1000ms \easeOutQuint
			$ '#registerForm .nickname .title' .animate {
				left: '64px'
				opacity: 0
			} 1000ms \easeOutQuint
			$ user-name-input-query .focus!

		function next
			$progress.attr \value 3

			$ '#registerForm .nickname' .css \transform 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)'
			$ '#registerForm .nickname' .animate {
				opacity: 0.2
			} 500ms \easeOutQuint

			$ '#registerForm .user-name' .css \transform 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)'

			$ '#registerForm .password' .animate {
				left: 0
				opacity: 1
			} 1000ms \easeOutElastic
			$ '#registerForm .password .title' .animate {
				left: 0
				opacity: 1
			} 2000ms \easeOutElastic
			$ password-input-query .focus!

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"nicknameAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ nickname-input-query .position!.top - 32px + ($ nickname-input-query .outer-height! / 2))
			$message.append-to '#registerForm .nickname' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#nicknameAvailable' .remove!

	function init-password-section
		right = no
		$back-button = $ '#registerForm .password button.back'
			..click back
		$next-button = $ '#registerForm .password button.next'
			..click next
		
		$ password-input-query .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ password-input-query .keyup ->
			right = no
			hide-message!
			$next-button.attr \disabled on
			password = $ password-input-query .val!
			if password.length > 0
				err = swicth
					| password.length < 8chars => '8文字以上でお願いします'
					| _ => null
				if err
					show-message err, no
				else
					show-message 'Nice!' yes
					$next-button.attr \disabled off
					right = yes
			else
				false

		function back
			$progress.attr \value 2

			$ '#registerForm .nickname' .css \transform 'perspective(512px) translateX(0) translateZ(0) rotateY(0)'
			$ '#registerForm .nickname' .animate {
				opacity: 1
			} 500ms \easeOutQuint

			$ '#registerForm .user-name' .css \transform 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)'

			$ '#registerForm .password' .animate {
				left: '100%'
				opacity: 0
			} 1000ms \easeOutQuint
			$ '#registerForm .password .title' .animate {
				left: '64px'
				opacity: 0
			} 1000ms \easeOutQuint
			$ nickname-input-query .focus!

		function next
			$progress.attr \value 4

			$ '#registerForm .password' .css \transform 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)'
			$ '#registerForm .password' .animate {
				opacity: 0.2
			} 500ms \easeOutQuint

			$ '#registerForm .user-name' .css \transform 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)'

			$ '#registerForm .nickname' .css \transform 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)'

			$ '#registerForm .password-retype' .animate {
				left: 0
				opacity: 1
			} 1000ms \easeOutElastic
			$ '#registerForm .password-retype .title' .animate {
				left: 0
				opacity: 1
			} 2000ms \easeOutElastic
			$ password-retype-input-query .focus!

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"passwordAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ password-input-query .position!.top - 32px + ($ password-input-query .outer-height! / 2))
			$message.append-to '#registerForm .password' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#passwordAvailable' .remove!

	function initPasswordRetypeSection() {
		var right = false;
		var $backButton = $('#registerForm .password-retype button.back')
		var $nextButton = $('#registerForm .password-retype button.next')

		$backButton.click(back);

		$nextButton.click(next);

		$(passwordRetypeInputQuery).on('keypress', function(event) {
			if (event.which == 13) {
				if (right) {
					next();
				}
				return false;
			} else {
				return true;
			}
		});

		$(passwordRetypeInputQuery).keyup(function() {
			right = false;
			hideMessage();
			$nextButton.attr('disabled', true);
			var password = $(passwordInputQuery).val();
			var passwordRetype = $(passwordRetypeInputQuery).val();
			if (passwordRetype.length == 0) {
				return false;
			}
			if (passwordRetype != password) {
				showMessage('一致していませんっ！', false);
				return false;
			}
			right = true;
			showMessage('Okay!', true);
			$nextButton.attr('disabled', false);
		});

		function back() {
			$progress.attr('value', 3);

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(0) translateZ(0) rotateY(0)');
			$('#registerForm .password').animate({
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password-retype').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .password-retype .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$(passwordInputQuery).focus();
		}

		function next() {
			$progress.attr('value', 5);

			$('#registerForm .password-retype').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');
			$('#registerForm .password-retype').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-600px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .user-color').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .user-color .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
			$(userColorInputQuery).focus();
		}

		function showMessage(message, success) {
			hideMessage();
			var klass = success == null ? '' : success ? 'done' : 'fail';
			var $message = $('<p id="passwordRetypeAvailable" class="message ' + klass + '">' + message + '</p>');
			$message.css('top', $(passwordRetypeInputQuery).position().top - 32 + ($(passwordRetypeInputQuery).outerHeight() / 2));
			$message.appendTo('#registerForm .password-retype').animate({
				'margin-right': 0,
				opacity: 1
			}, 500, 'easeOutCubic');
		}

		function hideMessage() {
			$('#passwordRetypeAvailable').remove();
		}
	}

	function initUserColorSection() {
		var right = false;
		var $backButton = $('#registerForm .user-color button.back')
		var $nextButton = $('#registerForm .user-color button.next')

		$backButton.click(back);

		$nextButton.click(next);

		$(userColorInputQuery).change(function() {
			hideMessage();
			var color = $(userColorInputQuery).val();
			right = true;
			showMessage('Good!', true);
			$nextButton.attr('disabled', false);
		});

		function back() {
			$progress.attr('value', 4);

			$('#registerForm .password-retype').css('transform', 'perspective(512px) translateX(0) translateZ(0) rotateY(0)');
			$('#registerForm .password-retype').animate({
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .user-color').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .user-color .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$(passwordRetypeInputQuery).focus();
		}

		function next() {
			$progress.attr('value', 6);

			$('#registerForm .user-color').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');
			$('#registerForm .user-color').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-700px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-600px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password-retype').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .confirm').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .confirm .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
		}

		function showMessage(message, success) {
			hideMessage();
			var klass = success == null ? '' : success ? 'done' : 'fail';
			var $message = $('<p id="userColorAvailable" class="message ' + klass + '">' + message + '</p>');
			$message.css('top', $(userColorInputQuery).position().top - 32 + ($(userColorInputQuery).outerHeight() / 2));
			$message.appendTo('#registerForm .user-color').animate({
				'margin-right': 0,
				opacity: 1
			}, 500, 'easeOutCubic');
		}

		function hideMessage() {
			$('#userColorAvailable').remove();
		}
	}

	function initConfirmSection() {
		var $backButton = $('#registerForm .confirm button.back')
		var $submitButton = $('#registerForm .confirm button.submit')

		$backButton.click(back);

		$submitButton.click(submit);

		function back() {
			$progress.attr('value', 5);

			$('#registerForm .user-color').css('transform', 'perspective(512px) translateX(0) translateZ(0) rotateY(0)');
			$('#registerForm .user-color').animate({
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .password-retype').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-600px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .confirm').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .confirm .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$(userColorInputQuery).focus();
		}

		function submit() {
			$progress.attr('value', 7);

			$('#registerForm .confirm').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');
			$('#registerForm .confirm').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-800px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-700px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(-600px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password-retype').css('transform', 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .user-color').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .complete').css({
				left: 0,
				opacity: 1
			});
			$('#registerForm .complete .title').css({
				left: 0,
				opacity: 1
			});
			swing($('#registerForm .complete'), 1);
		}
	}
}

function showRegisterForm() {
	$('#registerForm').css({
		display: 'block'
	});
	$('#registerForm .user-name').animate({
		left: 0,
		opacity: 1
	}, 500, 'easeOutQuint');
	$('#registerForm .user-name .title').animate({
		left: 0,
		opacity: 1
	}, 1000, 'easeOutElastic');
	$('#registerForm progress').attr('value', 1);
	$('#registerForm progress').css('height', '8px');
	$('#registerForm .user-name .user-name-input').focus();
}