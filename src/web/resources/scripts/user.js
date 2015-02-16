$(function() {
	$('#followButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($('html').prop('data-is-following') == true) {
			$.ajax('https://api.misskey.xyz/users/unfollow', {
				type: 'delete',
				data: JSON.stringify({ 'user_id': $('html').prop('data-user-id') }),
				processData: false,
				contentType: false,
				dataType: 'json',
				xhrFields: {
					withCredentials: true
				}
			}).done(function() {
				$button.attr('disabled', false);
				$button.removeClass('following');
				$button.addClass('notFollowing');
				$('html').prop('data-is-following', false)
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax('https://api.misskey.xyz/users/follow', {
				type: 'post',
				data: JSON.stringify({ 'user_id': $('html').prop('data-user-id') }),
				processData: false,
				contentType: false,
				dataType: 'json',
				xhrFields: {
					withCredentials: true
				}
			}).done(function() {
				$button.attr('disabled', false);
				$button.removeClass('notFollowing');
				$button.addClass('following');
				$('html').prop('data-is-following', true)
			}).fail(function() {
				$button.attr('disabled', false);
			});
		}
	});
});