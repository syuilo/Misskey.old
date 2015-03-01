var musicCenterOpen = false;

function updateStatuses() {
	$.ajax('https://api.misskey.xyz/account/unreadalltalks_count', {
		type: 'get',
		dataType: 'json',
		xhrFields: { withCredentials: true }
	}).done(function(result) {
		if ($("#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount")[0]) {
			$('#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount').remove();
		}
		if (result !== 0) {
			$("#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a").append(
				$('<span class="unreadCount">').text(result));
		}
	}).fail(function() {
	});
}

$(function() {
	updateStatuses();
	setInterval(updateStatuses, 5000);

	$("#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey").click(function() {
		if (musicCenterOpen) {
			$("#misskey-main-header > .informationCenter").css('width', '0');
		} else {
			$("#misskey-main-header > .informationCenter").css('width', '200px');
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