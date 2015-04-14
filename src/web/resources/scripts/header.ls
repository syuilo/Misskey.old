music-center-open = no

function update-statuses
	$.ajax "#{config.api-url}/account/unreadalltalks-count" {
		type: \get
		data-type: \json
		xhr-fields: {+withCredentials}}
	.done (result) ->
		if $ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount' .0
			$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a .unreadCount' .remove!
		if result != 0
			$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav ul .talk a' .append do
				$ '<span class="unreadCount">' .text result
	.fail ->

$ ->
	#update-statuses!
	#set-interval update-statuses, 5000ms

	$ '#misskey-main-header > .main .mainContentsContainer .left nav .mainNav .misskey' .click ->
		if music-center-open
			$ '#misskey-main-header > .informationCenter' .css \height '0'
		else
			$ '#misskey-main-header > .informationCenter' .css \height '200px'
		music-center-open = !music-center-open
	
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"

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
