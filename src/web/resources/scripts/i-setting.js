$(function() {
	function imageUpload(event, $form, url) {
		event.preventDefault();
		var $submitButton = $form.find("[type=submit]");
		fd = new FormData($form[0]);

		$submitButton.attr("disabled", true);
		$submitButton.attr("value", "アップロード中...");
		
		$.ajax({
			url: url,
			type: 'post',
			data: fd,
			processData: false,
			contentType: false,
			timeout: 10000,
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function(data) {
			location.reload();
		}).fail(function(data) {
			$submitButton.attr("disabled", false);
			$submitButton.attr("value", "失敗");
		});
	}

	$('main').tabs({
		show: {
			effect: "fadeIn",
			duration: 100,
			delay: 0
		},
		hide: {
			effect: "fadeOut",
			duration: 100,
			delay: 0
		}
	});

	$("#profileEditForm").submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find("[type=submit]");
		
		$submitButton.attr("disabled", true);
		$submitButton.attr("value", "保存中...");
		
		$.ajax({
			url: 'https://api.misskey.xyz/account/update',
			type: 'post',
			processData: false,
			contentType: false,
			data: new FormData($form[0]),
			dataType: "json",
			xhrFields: {
				withCredentials: true
			}
		}).done(function(data) {
			$submitButton.attr("value", "保存しました");
			$submitButton.attr("disabled", false);
		}).fail(function(data) {
			$submitButton.attr("disabled", false);
		});
	});
	
	$("#iconEditForm input[type=file]").change(function() {
		var file = $(this).prop('files')[0];
		if (!file.type.match('image.*')) {
			$("#iconEditForm .image").attr('src', "");
			return;
		}
		var reader = new FileReader();
		reader.onload = function() {
			$("#iconEditForm .image").attr('src', reader.result);
		};
		reader.readAsDataURL(file);
	});
	$("#wallpaperEditForm input[type=file]").change(function() {
		var file = $(this).prop('files')[0];
		if (!file.type.match('image.*')) {
			$("#wallpaperEditForm .image").attr('src', "");
			return;
		}
		var reader = new FileReader();
		reader.onload = function() {
			$("#wallpaperEditForm .image").attr('src', reader.result);
		};
		reader.readAsDataURL(file);
	});
	$("#headerEditForm input[type=file]").change(function() {
		var file = $(this).prop('files')[0];
		if (!file.type.match('image.*')) {
			$("#headerEditForm .image").attr('src', "");
			return;
		}
		var reader = new FileReader();
		reader.onload = function() {
			$("#headerEditForm .image").attr('src', reader.result);
		};
		reader.readAsDataURL(file);
	});
	
	$("#iconEditForm").submit(function(event) {
		imageUpload(event, $(this));
	});
	$("#wallpaperEditForm").submit(function(event) {
		imageUpload(event, $(this));
	});
	$("#headerEditForm").submit(function(event) {
		imageUpload(event, $(this));
	});
});