$(function() {
	$('#followButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($('html').data('is-following') == true) {
			$.ajax('https://api.misskey.xyz/users/unfollow', {
				type: 'delete',
				data: { 'user_id': $('html').data('user-id') },
				dataType: 'json',
				xhrFields: {
					withCredentials: true
				}
			}).done(function() {
				$button.attr('disabled', false);
				$button.removeClass('following');
				$button.addClass('notFollowing');
				$button.text('フォロー');
				$('html').data('data-is-following', 'false')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax('https://api.misskey.xyz/users/follow', {
				type: 'post',
				data: { 'user_id': $('html').data('user-id') },
				dataType: 'json',
				xhrFields: {
					withCredentials: true
				}
			}).done(function() {
				$button.attr('disabled', false);
				$button.removeClass('notFollowing');
				$button.addClass('following');
				$button.text('フォロー中');
				$('html').data('data-is-following', 'true')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		}
	});
});