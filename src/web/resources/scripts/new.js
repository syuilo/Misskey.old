var screenNameOk = false;

$(function() {
	$('#screenName').keyup(function() {
		$("#screenNameAvailable").remove();
		var sn = $('#screenName').val();

		if (sn == '') {
			return false;
		}
		if (sn.length < 4) {
			$('#screenName').before('<p id="screenNameAvailable" class="fail">4文字以上でお願いします</p>');
			return false;
		}
		if (sn.match(/^[0-9]+$/)) {
			$('#screenName').before('<p id="screenNameAvailable" class="fail">すべての文字を数字にすることはできません</p>');
			return false;
		}
		if (!sn.match(/^[a-zA-Z0-9_]+$/)) {
			$('#screenName').before('<p id="screenNameAvailable" class="fail">半角英数のみでお願いしますっ</p>');
			return false;
		}
		if (sn.length > 20) {
			$('#screenName').before('<p id="screenNameAvailable" class="fail">20文字以内でお願いします</p>');
			return false;
		}

		$('#screenName').before('<p id="screenNameAvailable">確認中...</p>');
		$.ajax('https://api.misskey.xyz/screenname_available', {
			type: 'get',
			data: { 'screen_name': sn },
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function(result) {
			$("#screenNameAvailable").remove();
			if (result) {
				$('#screenName').before('<p id="screenNameAvailable" class="fail">このIDは既に使用されていますっ</p>');
				screenNameOk = false;
			} else {
				$('#screenName').before('<p id="screenNameAvailable" class="done">このIDは使用できますっ！</p>');
				screenNameOk = true;
			}
		}).fail(function() {
		});
	});

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
		$submitButton.text('少々お待ちください...');

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
