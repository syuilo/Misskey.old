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
			$("#failed").remove();
			$("#icon").after("<p style='text-align: center; font-size: 0.8em; color: #f00;' id='failed'>ログインに失敗しました。パスワードが間違っている可能性があります</p>");
			setTimeout(function() {
				$form.css({
					"transform": "perspective(512px) scale(1)",
					"opacity": "1",
					"transition": "all ease 0.7s"
				});
			}, 500);
		});
	});
});

function showRegisterForm() {
	$('#registerForm').css({
		display: 'block'
	});
}

$('#new').click(function() {
	showRegisterForm();
});