$(function() {
	$("#loginForm").submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find("[type=submit]");

		$submitButton.attr("disabled", true);
		$form.css({
			"transform": "perspective(512px) rotateX(-90deg)",
			"opacity": "0",
			"transition": "all ease-in 0.5s"
		});

		$.ajax({
			url: $form.attr("action"),
			type: $form.attr("method"),
			data: $form.serialize()
		}).done(function() {
			location.reload();
		}).fail(function() {
			$submitButton.attr("disabled", false);
			setTimeout(function() {
				$form.css({
					"transform": "perspective(512px) scale(1)",
					"opacity": "1",
					"transition": "all ease 0.7s"
				});
			}, 500);
		});
	});

	$('#new').click(function() {
		showRegisterForm();
	});

	initRegisterForm();

	$('#color').change(function() {
		$("#colorAvailable").remove();
		var color = $('#color').val();
		$('#color').before('<p id="colorAvailable" class="done">Good!</p>');
	});

	$('#form').submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find('[type=submit]');

		$submitButton.attr('disabled', true);
		$submitButton.val('少々お待ちください...');

		$.ajax('https://api.misskey.xyz/account/create', {
			type: 'post',
			data: $form.serialize(),
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function(data) {
			location.href = 'https://misskey.xyz';
		}).fail(function(data) {
			$submitButton.attr('disabled', false);
			$submitButton.text('失敗しました :(');
		});
	});
});

function initRegisterForm() {
	var $progress = $('#registerForm progress');
	var userNameInputQuery = '#registerForm .user-name .user-name-input';
	var nicknameInputQuery = '#registerForm .nickname .nickname-input';
	var passwordInputQuery = '#registerForm .password .password-input';
	var passwordRetypeInputQuery = '#registerForm .password-retype .password-retype-input';

	initUserNameSection();
	initNicknameSection();
	initPasswordSection();
	initPasswordRetypeSection();

	function initUserNameSection() {
		var $cancelButton = $('#registerForm .user-name button.cancel')
		var $nextButton = $('#registerForm .user-name button.next')

		$nextButton.click(function() {
			$progress.attr('value', 2);

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-300px) translateZ(-100px)');
			$('#registerForm .user-name').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .nickname').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .nickname .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
		});

		$(userNameInputQuery).keyup(function() {
			$nextButton.attr('disabled', true);
			hideMessage();
			var sn = $(userNameInputQuery).val();

			if (sn == '') {
				return false;
			}
			if (sn.length < 4) {
				showMessage('4文字以上でお願いしますっ', false)
				return false;
			}
			if (sn.match(/^[0-9]+$/)) {
				showMessage('すべてを数字にすることはできませんっ', false)
				return false;
			}
			if (!sn.match(/^[a-zA-Z0-9_]+$/)) {
				showMessage('半角英数記号(_)のみでお願いしますっ', false)
				return false;
			}
			if (sn.length > 20) {
				showMessage('20文字以内でお願いします', false)
				return false;
			}

			showMessage('確認中...', null);
			$.ajax('https://api.misskey.xyz/screenname-available', {
				type: 'get',
				data: { 'screen-name': sn },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function(result) {
				if (result) {
					showMessage('このIDは既に使用されていますっ', false)
				} else {
					showMessage('このIDは使用できますっ！', true)
					$nextButton.attr('disabled', false);
				}
			}).fail(function() {
			});
		});

		function showMessage(message, success) {
			hideMessage();
			var klass = success == null ? '' : success ? 'done' : 'fail';
			var $message = $('<p id="userNameAvailable" class="message ' + klass + '">' + message + '</p>');
			$message.css('top', $(userNameInputQuery).position().top - 32 + ($(userNameInputQuery).outerHeight() / 2));
			$message.appendTo('#registerForm .user-name').animate({
				'margin-right': 0,
				opacity: 1
			}, 500, 'easeOutCubic');
		}

		function hideMessage() {
			$('#userNameAvailable').remove();
		}
	}

	function initNicknameSection() {
		var $backButton = $('#registerForm .nickname button.back')
		var $nextButton = $('#registerForm .nickname button.next')

		$backButton.click(function() {
			$progress.attr('value', 1);

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(0) translateX(0) translateZ(0)');
			$('#registerForm .user-name').animate({
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .nickname').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .nickname .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
		});

		$nextButton.click(function() {
			$progress.attr('value', 3);

			$('#registerForm .nickname').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-300px) translateZ(-100px)');
			$('#registerForm .nickname').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-600px) translateZ(-100px)');

			$('#registerForm .password').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .password .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
		});

		$(nicknameInputQuery).keyup(function() {
			hideMessage();
			$nextButton.attr('disabled', true);
			var name = $(nicknameInputQuery).val();
			if (name.length == 0) {
				return false;
			}
			showMessage('Great!', true);
			$nextButton.attr('disabled', false);
		});

		function showMessage(message, success) {
			hideMessage();
			var klass = success == null ? '' : success ? 'done' : 'fail';
			var $message = $('<p id="nicknameAvailable" class="message ' + klass + '">' + message + '</p>');
			$message.css('top', $(nicknameInputQuery).position().top - 32 + ($(nicknameInputQuery).outerHeight() / 2));
			$message.appendTo('#registerForm .nickname').animate({
				'margin-right': 0,
				opacity: 1
			}, 500, 'easeOutCubic');
		}

		function hideMessage() {
			$('#nicknameAvailable').remove();
		}
	}

	function initPasswordSection() {
		var $backButton = $('#registerForm .password button.back')
		var $nextButton = $('#registerForm .password button.next')

		$backButton.click(function() {
			$progress.attr('value', 2);

			$('#registerForm .nickname').css('transform', 'perspective(512px) rotateY(0) translateX(0) translateZ(0)');
			$('#registerForm .nickname').animate({
				left: 0,
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(0) translateX(-300px) translateZ(0)');

			$('#registerForm .password').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .password .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
		});

		$nextButton.click(function() {
			$progress.attr('value', 4);

			$('#registerForm .password').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-300px) translateZ(-100px)');
			$('#registerForm .password').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(0) translateX(-900px) translateZ(0)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) rotateY(0) translateX(-600px) translateZ(0)');

			$('#registerForm .password-retype').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .password-retype .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
		});

		$(passwordInputQuery).keyup(function() {
			hideMessage();
			$nextButton.attr('disabled', true);
			var password = $(passwordInputQuery).val();
			if (password.length == 0) {
				return false;
			}
			if (password.length < 8) {
				showMessage('8文字以上でお願いします', false);
				return false;
			}
			showMessage('Nice!', true);
			$nextButton.attr('disabled', false);
		});

		function showMessage(message, success) {
			hideMessage();
			var klass = success == null ? '' : success ? 'done' : 'fail';
			var $message = $('<p id="passwordAvailable" class="message ' + klass + '">' + message + '</p>');
			$message.css('top', $(passwordInputQuery).position().top - 32 + ($(passwordInputQuery).outerHeight() / 2));
			$message.appendTo('#registerForm .password').animate({
				'margin-right': 0,
				opacity: 1
			}, 500, 'easeOutCubic');
		}

		function hideMessage() {
			$('#passwordAvailable').remove();
		}
	}

	function initPasswordRetypeSection() {
		var $backButton = $('#registerForm .password-retype button.back')
		var $nextButton = $('#registerForm .password-retype button.next')

		$backButton.click(function() {
			$progress.attr('value', 3);

			$('#registerForm .password').css('transform', 'perspective(512px) rotateY(0) translateX(0) translateZ(0)');
			$('#registerForm .password').animate({
				left: 0,
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .nickname').css('transform', 'perspective(512px) rotateY(0) translateX(-300px) translateZ(0)');

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(0) translateX(-600px) translateZ(0)');

			$('#registerForm .password-retype').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .password-retype .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
		});

		$nextButton.click(function() {
			$progress.attr('value', 5);

			$('#registerForm .password-retype').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-300px) translateZ(-100px)');
			$('#registerForm .password-retype').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-1200px) translateZ(-100px)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-900px) translateZ(-100px)');

			$('#registerForm .password').css('transform', 'perspective(512px) rotateY(-45deg) translateX(-600px) translateZ(-100px)');

			$('#registerForm .user-color').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .user-color .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
		});

		$(passwordInputQuery).keyup(function() {
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
			showMessage('Okay!', true);
			$nextButton.attr('disabled', false);
		});

		function showMessage(message, success) {
			hideMessage();
			var klass = success == null ? '' : success ? 'done' : 'fail';
			var $message = $('<p id="passwordAvailable" class="message ' + klass + '">' + message + '</p>');
			$message.css('top', $(passwordRetypeInputQuery).position().top - 32 + ($(passwordRetypeInputQuery).outerHeight() / 2));
			$message.appendTo('#registerForm .password').animate({
				'margin-right': 0,
				opacity: 1
			}, 500, 'easeOutCubic');
		}

		function hideMessage() {
			$('#passwordAvailable').remove();
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
}