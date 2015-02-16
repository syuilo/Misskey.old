$(function() {
	$('#followButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($('html').attr('data-isFollowing') == true) {
			$.ajax('https://api.misskey.xyz/users/unfollow', {
				type: 'delete',
				data: { user_id: $('html').attr('data-userId') },
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
				$('html').attr('data-isFollowing', false)
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax('https://api.misskey.xyz/users/follow', {
				type: 'post',
				data: { user_id: $('html').attr('data-userId') },
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
				$('html').attr('data-isFollowing', true)
			}).fail(function() {
				$button.attr('disabled', false);
			});
		}
	});
});