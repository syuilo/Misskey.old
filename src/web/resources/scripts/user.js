$(function() {
	$('#followButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($('html').prop('data-isFollowing') == true) {
			$.ajax('https://api.misskey.xyz/users/unfollow', {
				type: 'delete',
				data: JSON.stringify({ 'user_id': $('html').prop('data-userId') }),
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
				$('html').prop('data-isFollowing', false)
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax('https://api.misskey.xyz/users/follow', {
				type: 'post',
				data: JSON.stringify({ 'user_id': $('html').prop('data-userId') }),
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
				$('html').prop('data-isFollowing', true)
			}).fail(function() {
				$button.attr('disabled', false);
			});
		}
	});
});