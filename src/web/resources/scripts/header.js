var musicCenterOpen = false;

function updateStatuses() {
	$.ajax(config.apiUrl + '/account/unreadalltalks-count', {
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
	//updateStatuses();
	//setInterval(updateStatuses, 5000);

	$("#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey").click(function() {
		if (musicCenterOpen) {
			$("#misskey-main-header > .informationCenter").css('height', '0');
		} else {
			$("#misskey-main-header > .informationCenter").css('height', '200px');
		}
		musicCenterOpen = !musicCenterOpen;
	});
	$("body").css("margin-top", $("body > #misskey-main-header").outerHeight() + "px");

	$('#misskey-main-header .notice .allDeleteButton').click(function() {
		$button = $(this);
		$button.attr('disabled', true);
		$.ajax(config.apiUrl + '/notice/deleteall', {
			type: 'delete',
			data: {},
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function() {
			$button.attr('disabled', false);
			$('#misskey-main-header .notice .notices .notice').each(function() {
				var $notice = $(this);
				$notice.css({
					transition: 'all 0.2s ease-in',
					transform: 'perspective(512px) translateY(20%) scale(0.8) rotateX(45deg)',
					opacity: 0
				});
				setTimeout(function() {
					$notice.remove();
				}, 300);
			});
		}).fail(function() {
			$button.attr('disabled', false);
		});
	});

	$("#misskey-main-header .search input").bind('input', function() {
		var $result = $("#misskey-main-header .search .result");
		if ($(this).val() == '') {
			$result.empty();
			return;
		}
		$.ajax(config.apiUrl + '/search/user', {
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
								'href': config.url + '/' + user.screenName,
								'title': user.comment,
							}).append(
								$('<img class="icon" alt="icon">').attr('src', config.url + '/img/icon/' + user.screenName)
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
