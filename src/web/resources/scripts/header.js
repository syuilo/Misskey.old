var musicCenterOpen = false;

$(function() {
	$.ajax('https://api.misskey.xyz/account/unreadalltalks_count', {
		type: 'get',
		dataType: 'json',
		xhrFields: { withCredentials: true }
	}).done(function(result) {
		if (result !== 0) {
			$("#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a").append(
				$('<span class="unreadCount">').text(result));
		}
	}).fail(function() {
	});

	$("#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey").click(function() {
		if (musicCenterOpen) {
			$("#misskey-musicCenter").css('top', '-100%');
		} else {
			$("#misskey-musicCenter").css('top', '0');
		}
		musicCenterOpen = !musicCenterOpen;
	});
	$("body").css("margin-top", $("body > #misskey-main-header").outerHeight() + "px");

	$("#misskey-main-header .search input").keyup(function() {
		var $result = $("#misskey-main-header .search .result");
		if ($(this).val() == '') {
			$result.empty();
			return;
		}
		$.ajax('https://api.misskey.xyz/search/user', {
			type: 'get',
			data: { 'query': $(this).val() },
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function(result) {
			$result.empty();
			if (result.length > 0) {
				$result.append($('<ol class="users">'));
				result.forEach(function(user) {
					$result.find('ol').append(
						$('<li>').append(
							$('<a>').attr({
								'href': 'https://misskey.xyz/' + user.screenName,
								'title': user.comment,
							}).append(
								$('<img class="icon" alt="icon">').attr('src', 'https://misskey.xyz/img/icon/' + user.screenName)
							).append(
								$('<span class="name">').text(user.name)
							).append(
								$('<span class="screenName">').text('@' + user.screenName)
							)
						)
					);
				});
			}
		}).fail(function() {
		});
	});
});

$(window).load(function() {
	$("body").css("margin-top", $("body > #misskey-main-header").outerHeight() + "px");
});