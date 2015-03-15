$(function() {
	function imageUpload(event, $form, url) {
		event.preventDefault();
		var $submitButton = $form.find("[type=submit]");
		fd = new FormData($form[0]);

		$submitButton.attr("disabled", true);
		$submitButton.attr("value", "アップロード中...");
		
		$.ajax(url, {
			type: 'PUT',
			data: fd,
			processData: false,
			contentType: false,
			timeout: 20000,
			dataType: 'json',
			headers: {
				'X-HTTP-Method-Override': 'PUT'
			},
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

	SYUILOUI.Tab($('main > nav > ul'));

	$("#profileEditForm").submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find("[type=submit]");
		
		$submitButton.attr("disabled", true);
		$submitButton.attr("value", "保存中...");
		
		$.ajax('https://api.misskey.xyz/account/update', {
			type: 'PUT',
			processData: false,
			contentType: false,
			data: new FormData($form[0]),
			dataType: "json",
			headers: {
				'X-HTTP-Method-Override': 'PUT'
			},
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
		imageUpload(event, $(this), 'https://api.misskey.xyz/account/update_icon');
	});
	$("#wallpaperEditForm").submit(function(event) {
		imageUpload(event, $(this), 'https://api.misskey.xyz/account/update_wallpaper');
	});
	$("#headerEditForm").submit(function(event) {
		imageUpload(event, $(this), 'https://api.misskey.xyz/account/update_header');
	});
});