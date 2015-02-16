$(function() {
	$(window).resize(function() {
		if ($(window).width() < $('main').css('max-width')) {
			$('#headerUserAreaBackground').css('width', $(window).width() + 'px')
		} else {
			$('#headerUserAreaBackground').css('width', $('main').css('max-width') + 'px')
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