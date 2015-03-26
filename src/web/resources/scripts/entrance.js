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
});

function showRegisterForm() {
	$('#registerForm').css({
		display: 'block'
	});
	setTimeout(function() {
		$('#registerForm .user-name').css({
			left: 0
		});
	}, 100);
}