$(function() {
	swing($("#loginForm"), 100);

	function swing($elem, force) {
		var baseForce = force;
		var pos = force;
		var t = 0;
		var timeer = setInterval(update, 10);

		function update() {
			t++;
			force -= 0.1;
			if (force <= 0) {
				clearInterval(timer);
			}
			pos = (Math.sin(t) / (baseForce - force));
			$elem.css('transform', 'rotateX(' + pos + 'deg)');
		}
	}

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
});

function initRegisterForm() {
	var $progress = $('#registerForm progress');
	var userNameInputQuery = '#registerForm .user-name .user-name-input';
	var nicknameInputQuery = '#registerForm .nickname .nickname-input';
	var passwordInputQuery = '#registerForm .password .password-input';
	var passwordRetypeInputQuery = '#registerForm .password-retype .password-retype-input';
	var userColorInputQuery = '#registerForm .user-color .user-color-input';

	initUserNameSection();
	initNicknameSection();
	initPasswordSection();
	initPasswordRetypeSection();
	initUserColorSection();
	initConfirmSection();

	$('#registerForm form').submit(function(event) {
		event.preventDefault();
		var $form = $(this);

		$.ajax('https://api.misskey.xyz/account/create', {
			type: 'post',
			data: $form.serialize(),
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function(data) {
			location.href = 'https://misskey.xyz';
		}).fail(function(data) {
		});
	});

	function initUserNameSection() {
		var right = false;
		var $cancelButton = $('#registerForm .user-name button.cancel')
		var $nextButton = $('#registerForm .user-name button.next')

		$cancelButton.click(cancel);

		$nextButton.click(next);

		$(userNameInputQuery).on('keypress', function(event) {
			if (event.which == 13) {
				if (right) {
					next();
				}
				return false;
			} else {
				return true;
			}
		});

		$(userNameInputQuery).keyup(function() {
			right = false;
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
					right = false;
					showMessage('このIDは既に使用されていますっ', false)
				} else {
					right = true;
					showMessage('このIDは使用できますっ！', true)
					$nextButton.attr('disabled', false);
				}
			}).fail(function() {
				showMessage('確認に失敗しました;;', null);
			});
		});

		function cancel() {
			$('#registerForm .user-name').animate({
				left: '100%',
				opacity: 0
			}, 500, 'easeOutQuint');
			$('#registerForm .user-name .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm progress').css('height', 0);
			$('#registerForm progress').attr('value', 0);

			setTimeout(function() {
				$('#registerForm').css({
					display: 'none'
				});
			}, 500);
		}

		function next() {
			$progress.attr('value', 2);

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');
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
			$(nicknameInputQuery).focus();
		}

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
		var right = false;
		var $backButton = $('#registerForm .nickname button.back')
		var $nextButton = $('#registerForm .nickname button.next')

		$backButton.click(back);

		$nextButton.click(next);

		$(nicknameInputQuery).on('keypress', function(event) {
			if (event.which == 13) {
				if (right) {
					next();
				}
				return false;
			} else {
				return true;
			}
		});

		$(nicknameInputQuery).keyup(function() {
			right = false;
			hideMessage();
			$nextButton.attr('disabled', true);
			var name = $(nicknameInputQuery).val();
			if (name.length == 0) {
				return false;
			}
			right = true;
			showMessage('Great!', true);
			$nextButton.attr('disabled', false);
		});

		function back() {
			$progress.attr('value', 1);

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(0) translateZ(0) rotateY(0)');
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
			$(userNameInputQuery).focus();
		}

		function next() {
			$progress.attr('value', 3);

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');
			$('#registerForm .nickname').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .password .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
			$(passwordInputQuery).focus();
		}

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
		var right = false;
		var $backButton = $('#registerForm .password button.back')
		var $nextButton = $('#registerForm .password button.next')

		$backButton.click(back);

		$nextButton.click(next);

		$(passwordInputQuery).on('keypress', function(event) {
			if (event.which == 13) {
				if (right) {
					next();
				}
				return false;
			} else {
				return true;
			}
		});

		$(passwordInputQuery).keyup(function() {
			right = false;
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
			right = true;
		});

		function back() {
			$progress.attr('value', 2);

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(0) translateZ(0) rotateY(0)');
			$('#registerForm .nickname').animate({
				opacity: 1
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password').animate({
				left: '100%',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$('#registerForm .password .title').animate({
				left: '64px',
				opacity: 0
			}, 1000, 'easeOutQuint');
			$(nicknameInputQuery).focus();
		}

		function next() {
			$progress.attr('value', 4);

			$('#registerForm .password').css('transform', 'perspective(512px) translateX(-300px) translateZ(-100px) rotateY(-45deg)');
			$('#registerForm .password').animate({
				opacity: 0.2
			}, 500, 'easeOutQuint');

			$('#registerForm .user-name').css('transform', 'perspective(512px) translateX(-500px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .nickname').css('transform', 'perspective(512px) translateX(-400px) translateZ(-100px) rotateY(-45deg)');

			$('#registerForm .password-retype').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .password-retype .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
			$(passwordRetypeInputQuery).focus();
		}

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

			$('#registerForm .complete').animate({
				left: 0,
				opacity: 1
			}, 1000, 'easeOutElastic');
			$('#registerForm .complete .title').animate({
				left: 0,
				opacity: 1
			}, 2000, 'easeOutElastic');
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