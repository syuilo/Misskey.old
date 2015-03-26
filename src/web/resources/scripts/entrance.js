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

	initUserNameValidater();

	

	$('#name').keyup(function() {
		$("#nameAvailable").remove();
		var name = $('#name').val();
		if (name.length == 0) {
			return false;
		}
		$('#name').before('<p id="nameAvailable" class="done">Great!</p>');
	});

	$('#password').keyup(function() {
		$("#passwordAvailable").remove();
		var password = $('#password').val();
		if (password.length == 0) {
			return false;
		}
		if (password.length < 8) {
			$('#password').before('<p id="passwordAvailable" class="fail">8文字以上でお願いします</p>');
			return false;
		}
		$('#password').before('<p id="passwordAvailable" class="done">Nice!</p>');
	});

	$('#passwordRetype').keyup(function() {
		$("#passwordRetypeAvailable").remove();
		var password = $('#password').val();
		var passwordRetype = $('#passwordRetype').val();
		if (passwordRetype.length == 0) {
			return false;
		}
		if (passwordRetype != password) {
			$('#passwordRetype').before('<p id="passwordRetypeAvailable" class="fail">一致していませんっ</p>');
			return false;
		}
		$('#passwordRetype').before('<p id="passwordRetypeAvailable" class="done">Okay!</p>');
	});

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

function initUserNameValidater() {
	var userNameQuery = '#registerForm .user-name .user-name-input';
	var $nextButton = $('#registerForm .user-name button.next')

	$(userNameQuery).keyup(function() {
		$nextButton.attr('disabled', true);
		hideMessage();
		var sn = $(userNameQuery).val();

		if (sn == '') {
			return false;
		}
		if (sn.length < 4) {
			showMessage('4文字以上でお願いしますっ', false)
			return false;
		}
		if (sn.match(/^[0-9]+$/)) {
			showMessage('すべての文字を数字にすることはできませんっ', false)
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
		$message.appendTo('#registerForm .user-name').animate({ 
			right: "calc(100% + -8px)",
			opacity: 1
		}, 500, 'easeOutCubic');
	}

	function hideMessage() {
		$('#userNameAvailable').remove();
	}
}

function showRegisterForm() {
	$('#registerForm').css({
		display: 'block'
	});
	setTimeout(function() {
		$('#registerForm .user-name').css({
			left: 0,
			opacity: 1
		});
	}, 100);
}