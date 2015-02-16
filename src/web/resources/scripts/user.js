$(function() {
	$(window).resize(function() {
		var windowWidth = $(window).width();
		var maxWidth = parseInt($('main').css('max-width'));
		if (windowWidth < maxWidth) {
			$('#headerUserAreaBackground').css('width', windowWidth + 'px')
		} else {
			$('#headerUserAreaBackground').css('width', maxWidth + 'px')
		}
	});

	$('#followButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($('html').attr('data-is-following') == 'true') {
			$.ajax('https://api.misskey.xyz/users/unfollow', {
				type: 'delete',
				data: { 'user_id': $('html').attr('data-user-id') },
				dataType: 'json',
				xhrFields: {
					withCredentials: true
				}
			}).done(function() {
				$button.attr('disabled', false);
				$button.removeClass('following');
				$button.addClass('notFollowing');
				$button.text('フォロー');
				$('html').attr('data-is-following', 'false')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax('https://api.misskey.xyz/users/follow', {
				type: 'post',
				data: { 'user_id': $('html').attr('data-user-id') },
				dataType: 'json',
				xhrFields: {
					withCredentials: true
				}
			}).done(function() {
				$button.attr('disabled', false);
				$button.removeClass('notFollowing');
				$button.addClass('following');
				$button.text('フォロー中');
				$('html').attr('data-is-following', 'true')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		}
	});
});